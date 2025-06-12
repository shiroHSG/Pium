package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.dto.chat.InviteCheckResponseDTO;
import com.buddy.pium.dto.chat.InviteLinkResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.exception.BusinessException;
import com.buddy.pium.exception.InvalidChatRoomOperationException;
import com.buddy.pium.exception.InvalidPasswordException;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.chat.ChatRoomBanRepository;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.repository.chat.MessageRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareRepository;
import com.buddy.pium.service.FileUploadService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import org.apache.commons.lang3.RandomStringUtils;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final MessageRepository messageRepository;
    private final FileUploadService fileUploadService;
    private final ChatRoomBanRepository chatRoomBanRepository;

    private final ChatRoomMemberService chatRoomMemberService;

    //direct(개인, 나눔) dto 전달
    public ChatRoomResponseDTO getOrCreateChatRoom(ChatRoomRequestDTO dto, MultipartFile image, Member member) {
        Enum.ChatRoomType type = dto.getType();

        return switch (type) {
            case DIRECT, SHARE -> handleDirectOrShareChatRoom(dto, member);
            case GROUP -> handleGroupChatRoom(dto, image, member);
        };
    }

    private ChatRoomResponseDTO handleDirectOrShareChatRoom(ChatRoomRequestDTO dto, Member sender) {
        Enum.ChatRoomType type = dto.getType();
        Long shareId = dto.getShareId();

        Member receiver = validateMember(dto.getReceiverId());

        // 자기 자신에게 메세지 전달 불가
        if (sender.equals(receiver)) {
            throw new BusinessException("자기 자신과는 채팅할 수 없습니다.");
        }

        // 나눔 게시글 확인 (SHARE일 경우만)
        Share share = validateSharePost(type, shareId);

        // 기존 채팅방 있는지 확인
        Optional<ChatRoom> optionalRoom =
                chatRoomRepository.findExistingDirectRoom(sender, receiver, type, shareId);
        if (optionalRoom.isPresent()) {
            return toResponseDTO(optionalRoom.get(), sender);
        }

        // 새로운 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .type(type)
                .share(share)
                .build();
        chatRoomRepository.save(chatRoom);

        // 참여자 등록
        chatRoomMemberRepository.saveAll(List.of(
                createChatRoomMember(chatRoom, sender, false),
                createChatRoomMember(chatRoom, receiver, false)
        ));
        return toResponseDTO(chatRoom, sender);
    }

    private ChatRoomResponseDTO handleGroupChatRoom(ChatRoomRequestDTO dto, MultipartFile image, Member creator) {
        // 필수값 검증
        String roomName = dto.getChatRoomName();
        if (roomName == null || roomName.trim().isEmpty()) {
            throw new IllegalArgumentException("그룹 채팅방 이름은 필수입니다.");
        }

        // 이미지 로컬에 저장
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "chatrooms"); // 폴더명 chatrooms
        }

        // 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .type(Enum.ChatRoomType.GROUP)
                .chatRoomName(roomName)     // required
                .password(dto.getPassword())       // optional
                .imageUrl(imageUrl)       // optional
                .inviteCode(RandomStringUtils.randomAlphanumeric(10))
                .build();

        chatRoomRepository.save(chatRoom);

        chatRoomMemberRepository.save(createChatRoomMember(chatRoom, creator, true));

        return toResponseDTO(chatRoom, creator);
    }

    // 채팅방 리스트 조회
    public List<ChatRoomResponseDTO> getChatRoomsForMember(Member member) {
        List<ChatRoom> chatRooms = chatRoomRepository.findAllByMemberWithMembers(member);

        return chatRooms.stream()
                .sorted(Comparator.comparing(
                        ChatRoom::getLastMessageSentAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .map(chatRoom -> toResponseDTO(chatRoom, member))
                .collect(Collectors.toList());
    }

    // 마지막 메세지, 읽지 못한 메세지 수, 상대방 정보 포함
    private ChatRoomResponseDTO toResponseDTO(ChatRoom chatRoom, Member currentUser) {
        String otherNickname = null;
        String otherProfileImageUrl = null;

        // lastReadMessageId 조회
        ChatRoomMember chatRoomMember = chatRoomMemberService.validateChatRoomMember(chatRoom, currentUser);
        Long lastReadMessageId = chatRoomMember.getLastReadMessageId();

        int unreadCount;
        if (lastReadMessageId == null) {
            unreadCount = messageRepository.countByChatRoomAndSenderNot(chatRoom, currentUser);
        } else {
            unreadCount = messageRepository.countByChatRoomAndIdGreaterThanAndSenderNot(
                    chatRoom, lastReadMessageId, currentUser);
        }

        if (chatRoom.getType() == Enum.ChatRoomType.DIRECT || chatRoom.getType() == Enum.ChatRoomType.SHARE) {
            // 나와 다른 사용자 찾기
            Member other = chatRoomMemberRepository.findByChatRoom(chatRoom).stream()
                    .map(ChatRoomMember::getMember)
                    .filter(member -> !member.getId().equals(currentUser.getId()))
                    .findFirst()
                    .orElse(null);

            if (other != null) {
                otherNickname = other.getNickname();
                otherProfileImageUrl = other.getProfileImageUrl();
            }
        }

        return ChatRoomResponseDTO.builder()
                .chatRoomId(chatRoom.getId())
                .type(chatRoom.getType())
                .chatRoomName(chatRoom.getChatRoomName())
                .imageUrl(chatRoom.getImageUrl())
                .lastMessage(chatRoom.getLastMessageContent())
                .lastSentAt(chatRoom.getLastMessageSentAt())
                .sharePostId(chatRoom.getShare() != null ? chatRoom.getShare().getId() : null)
                .otherNickname(otherNickname)
                .otherProfileImageUrl(otherProfileImageUrl)
                .unreadCount(unreadCount)
                .build();
    }

    // 채팅방 수정
    @Transactional
    public void updateGroupChatRoom(Long chatRoomId, ChatRoomRequestDTO dto, MultipartFile image, Member member) {

        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);
        ChatRoomMember admin = chatRoomMemberService.validateChatRoomMember(chatRoom, member);
        chatRoomMemberService.validateAdminAuth(admin);

        // 채팅방 이름 수정
        if (dto.getChatRoomName() != null) {
            chatRoom.setChatRoomName(dto.getChatRoomName());
        }

        // 비밀번호 수정
        if (dto.getPassword() != null) {
            chatRoom.setPassword(dto.getPassword());
        }

        // 이미지 수정 (기존 이미지가 있다면 삭제 후 새로 저장)
        if (image != null && !image.isEmpty()) {
            if (chatRoom.getImageUrl() != null) {
                fileUploadService.delete(chatRoom.getImageUrl());
            }

            String imageUrl = fileUploadService.upload(image, "chatrooms");
            chatRoom.setImageUrl(imageUrl);
        }
        chatRoomRepository.save(chatRoom);
    }

    // 채팅방 떠나기
    @Transactional
    public void leaveChatRoom(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateChatRoom(chatRoomId);
        ChatRoomMember chatRoomMember = chatRoomMemberService.validateChatRoomMember(chatRoom, member);
        chatRoomMemberRepository.delete(chatRoomMember);

        // 남은 인원 수 0 일시 이미지 및 채팅방 삭제
        int remainingMembers = chatRoomMemberRepository.countByChatRoom(chatRoom);
        if (remainingMembers == 0) {
            deleteChatRooom(chatRoom);
        }
    }

    // 채팅방 방장이 삭제
    @Transactional
    public void deleteGroupChatRoom(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);
        ChatRoomMember admin = chatRoomMemberService.validateChatRoomMember(chatRoom, member);
        chatRoomMemberService.validateAdminAuth(admin);
        deleteChatRooom(chatRoom);
    }

    // 초대 코드 가져오기
    @Transactional
    public InviteLinkResponseDTO getInviteLink(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);

        if (!chatRoomMemberService.isMember(chatRoom, member)) {
            throw new AccessDeniedException("해당 채팅방에 속한 멤버만 초대 링크를 조회할 수 있습니다.");
        }

        return new InviteLinkResponseDTO(chatRoom.getInviteCode(), "http://localhost:8080/chat/invite/" + chatRoom.getInviteCode());
    }

    // 초대 링크 정보 조회
    @Transactional
    public InviteCheckResponseDTO checkInviteAccess(String inviteCode, Member member) {
        ChatRoom chatRoom = validateInviteCode(inviteCode);
        isTypeGroupChatRoom(chatRoom);
        isBannedMember(chatRoom, member);

        return new InviteCheckResponseDTO(
                chatRoom.getChatRoomName(),
                chatRoomMemberService.isMember(chatRoom, member),
                !chatRoomMemberService.isMember(chatRoom, member) && (chatRoom.getPassword() != null && !chatRoom.getPassword().isBlank()) // 이미 입장한 사람은 비밀번호 X
        );
    }

    // 비밀번호 확인 및 멤버 등록
    @Transactional
    public Long enterChatRoomViaInvite(String inviteCode, Member member, String password) {
        ChatRoom chatRoom = validateInviteCode(inviteCode);
        isTypeGroupChatRoom(chatRoom);
        isBannedMember(chatRoom, member);

        // 이미 입장 완료 → 바로 채팅방 ID 반환
        if (chatRoomMemberService.isMember(chatRoom, member)) {
            return chatRoom.getId();
        }

        // 비밀번호 검증 (null-safe)
        String actualPassword = chatRoom.getPassword();
        if (actualPassword != null && !actualPassword.isBlank()) {
            if (!actualPassword.equals(password)) {
                throw new InvalidPasswordException("비밀번호가 일치하지 않습니다.");
            }
        }
        chatRoomMemberRepository.save(createChatRoomMember(chatRoom, member, false));
        return chatRoom.getId();
    }

    // 유효 유저 확인
    private Member validateMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("보내는 유저가 존재하지 않습니다."));
    }

    // 유효 SharePost 확인
    private Share validateSharePost(Enum.ChatRoomType type, Long shareId) {
        if (type == Enum.ChatRoomType.SHARE) {
            if (shareId == null) {
                throw new IllegalArgumentException("나눔 채팅방은 shareId가 필요합니다.");
            }
            return shareRepository.findById(shareId)
                    .orElseThrow(() -> new ResourceNotFoundException("해당 나눔글이 존재하지 않습니다."));
        }
        else {
            return null;
        }
    }

    // 채팅방 멤버 생성
    private ChatRoomMember createChatRoomMember(ChatRoom chatRoom, Member member, boolean isAdmin) {
        return ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(member)
                .isAdmin(isAdmin)
                .build();
    }

    // 유효 그룹 채팅방 확인
    private ChatRoom validateGroupChatRoom(Long chatRoomId) {
        ChatRoom chatRoom = validateChatRoom(chatRoomId);
        isTypeGroupChatRoom(chatRoom);
        return chatRoom;
    }


    public ChatRoom validateChatRoom(Long chatRoomId) {
        return chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방을 찾을 수 없습니다."));
    }

    private ChatRoom validateInviteCode(String inviteCode) {
        return chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("초대 코드가 유효하지 않습니다."));
    }

    private void isTypeGroupChatRoom(ChatRoom chatRoom) {
        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new InvalidChatRoomOperationException("그룹 채팅방이 아닙니다.");
        }
    }

    private void isBannedMember(ChatRoom chatRoom, Member member) {
        if (chatRoomBanRepository.existsByChatRoomAndBannedMember(chatRoom, member)) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }
    }

    private void deleteChatRooom(ChatRoom chatRoom) {
        if (chatRoom.getImageUrl() != null) {
            fileUploadService.delete(chatRoom.getImageUrl());
        }
        chatRoomRepository.delete(chatRoom);
    }
}
