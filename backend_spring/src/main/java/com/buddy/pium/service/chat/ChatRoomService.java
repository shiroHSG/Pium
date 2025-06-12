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
        Long receiverId = dto.getReceiverId();
        Long shareId = dto.getShareId();

        Member receiver = memberRepository.findById(receiverId)
                .orElseThrow(() -> new EntityNotFoundException("받는 유저가 존재하지 않습니다."));

        // 자기 자신에게 메세지 전달 불가
        if (sender.equals(receiver)) {
            throw new IllegalArgumentException("자기 자신과는 채팅할 수 없습니다.");
        }

        // 📦 나눔 게시글 확인 (SHARE일 경우만)
        Share share = null;
        if (type == Enum.ChatRoomType.SHARE) {
            if (shareId == null) {
                throw new IllegalArgumentException("나눔 채팅방은 sharePostId가 필요합니다.");
            }
            share = shareRepository.findById(shareId)
                    .orElseThrow(() -> new EntityNotFoundException("해당 나눔글이 존재하지 않습니다."));
        }


        // 🔍 기존 채팅방 있는지 확인
        Optional<ChatRoom> optionalRoom =
                chatRoomRepository.findExistingDirectRoom(sender, receiver, type, shareId);
        if (optionalRoom.isPresent()) {
            return toResponseDTO(optionalRoom.get(), sender);
        }

        // 🏗 새로운 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .type(type)
                .share(share)
                .build();
        chatRoomRepository.save(chatRoom);


        // 👥 참여자 등록
        chatRoomMemberRepository.saveAll(List.of(
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(sender)
                        .isAdmin(false)
                        .build(),
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(receiver)
                        .isAdmin(false)
                        .build()
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
                .chatRoomName(roomName)
                .password(dto.getPassword())       // optional
                .imageUrl(imageUrl)       // optional
                .inviteCode(RandomStringUtils.randomAlphanumeric(10))
                .build();

        chatRoomRepository.save(chatRoom);

        // 생성자만 입장 (관리자)
        ChatRoomMember creatorMember = ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(creator)
                .isAdmin(true)
                .build();

        chatRoomMemberRepository.save(creatorMember);

        return toResponseDTO(chatRoom, creator);
    }

    // 채팅방 리스트 조회
    public List<ChatRoomResponseDTO> getChatRoomsForMember(Member member) {
        List<ChatRoom> chatRooms = chatRoomRepository.findAllByMemberIdWithMembers(member.getId());

        return chatRooms.stream()
                .sorted(Comparator.comparing(
                        ChatRoom::getLastMessageSentAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .map(chatRoom -> toResponseDTO(chatRoom, member))
                .collect(Collectors.toList());
    }


    private ChatRoomResponseDTO toResponseDTO(ChatRoom chatRoom, Member currentUser) {
        String otherNickname = null;
        String otherProfileImageUrl = null;

        // lastReadMessageId 조회
        ChatRoomMember chatRoomMember = chatRoomMemberRepository
                .findByChatRoomAndMember(chatRoom, currentUser)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 멤버가 아닙니다."));

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
        //채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("그룹 채팅방만 수정할 수 있습니다.");
        }

        ChatRoomMember admin = chatRoomMemberRepository.findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 멤버가 아닙니다."));

        // 로그인한 사용자 = 방장인지 확인
        if (!admin.isAdmin()) {
            throw new IllegalArgumentException("채팅방을 수정할 권한이 없습니다.");
        }

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

        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));


        // ChatRoomMember 조회 및 삭제
        ChatRoomMember chatRoomMember = chatRoomMemberRepository.findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new IllegalArgumentException("채팅방에 참여 중이지 않습니다."));

        chatRoomMemberRepository.delete(chatRoomMember);

        // 남은 인원 수 확인
        int remainingMembers = chatRoomMemberRepository.countByChatRoom(chatRoom);

        if (remainingMembers == 0) {
            // 이미지 삭제 (있다면)
            if (chatRoom.getImageUrl() != null) {
                fileUploadService.delete(chatRoom.getImageUrl());
            }

            // 채팅방 삭제
            chatRoomRepository.delete(chatRoom);
        }
    }

    // 채팅방 방장이 삭제
    @Transactional
    public void deleteGroupChatRoom(Long chatRoomId, Member member) {
        // 1. 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방이 존재하지 않습니다."));

        // 2. 그룹 채팅방인지 확인
        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("그룹 채팅방만 수정할 수 있습니다.");
        }

        // 3. 방장이 맞는지 확인
        ChatRoomMember admin = chatRoomMemberRepository
                .findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new IllegalArgumentException("해당 채팅방에 참여 중이지 않습니다."));

        if (!admin.isAdmin()) {
            throw new IllegalArgumentException("방장만 채팅방을 삭제할 수 있습니다.");
        }

        //
        chatRoomRepository.delete(chatRoom);
    }

    // 초대 코드 가져오기
    @Transactional
    public InviteLinkResponseDTO getInviteLink(Long chatRoomId, Member member) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용할 수 있습니다.");
        }

        // (옵션) 요청자가 이 채팅방의 멤버인지 검증
        boolean isMember = chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
        if (!isMember) {
            throw new IllegalArgumentException("해당 채팅방에 속한 멤버만 초대 링크를 조회할 수 있습니다.");
        }

        String baseUrl = "http://localhost:8080/chat/invite/";
        String inviteCode = chatRoom.getInviteCode();

        return new InviteLinkResponseDTO(inviteCode, baseUrl + inviteCode);
    }

    // 초대 링크 정보 조회
    @Transactional
    public InviteCheckResponseDTO checkInviteAccess(String inviteCode, Member member) {
        ChatRoom chatRoom = chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("유효하지 않은 초대 코드입니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용할 수 있습니다.");
        }

        // 밴 여부 확인
        boolean isBanned = chatRoomBanRepository.existsByChatRoomAndBannedMember(chatRoom, member);
        if (isBanned) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }

        boolean isMember = chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
        boolean requirePassword = (chatRoom.getPassword() != null && !chatRoom.getPassword().isBlank());


        return new InviteCheckResponseDTO(
                chatRoom.getChatRoomName(),
                isMember,
                isMember ? false : requirePassword // 이미 입장한 사람은 비밀번호 X
        );
    }

    // 비밀번호 확인 및 멤버 등록
    @Transactional
    public Long enterChatRoomViaInvite(String inviteCode, Member member, String password) {
        ChatRoom chatRoom = chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("초대 코드가 유효하지 않습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용 가능합니다.");
        }

        // 밴 여부 확인
        boolean isBanned = chatRoomBanRepository.existsByChatRoomAndBannedMember(chatRoom, member);
        if (isBanned) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }

        // 이미 멤버인지 확인
        boolean isMember = chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
        if (isMember) {
            return chatRoom.getId(); // 이미 입장 완료 → 바로 채팅방 ID 반환
        }

        // 비밀번호 검증 (null-safe)
        String actualPassword = chatRoom.getPassword();
        if (actualPassword != null && !actualPassword.isBlank()) {
            if (!actualPassword.equals(password)) {
                throw new AccessDeniedException("비밀번호가 일치하지 않습니다.");
            }
        }

        ChatRoomMember newMember = ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(member)
                .isAdmin(false)
                .build();

        chatRoomMemberRepository.save(newMember);

        return chatRoom.getId();
    }

    // 유효 유저 확인
    private Member validateMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new EntityNotFoundException("보내는 유저가 존재하지 않습니다."));
    }
}
