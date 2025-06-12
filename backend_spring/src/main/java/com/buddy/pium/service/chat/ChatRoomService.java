package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.dto.chat.InviteCheckResponseDTO;
import com.buddy.pium.dto.chat.InviteLinkResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.SharePost;
import com.buddy.pium.repository.chat.ChatRoomBanRepository;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.repository.chat.MessageRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.SharePostRepository;
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
    private final SharePostRepository sharePostRepository;
    private final MemberRepository memberRepository;
    private final MessageRepository messageRepository;
    private final FileUploadService fileUploadService;
    private final ChatRoomBanRepository chatRoomBanRepository;

    //direct(개인, 나눔) dto 전달
    public ChatRoomResponseDTO getOrCreateChatRoom(ChatRoomRequestDTO dto, MultipartFile image, Long currentUserId) {
        Enum.ChatRoomType type = dto.getType();

        return switch (type) {
            case DIRECT, SHARE -> handleDirectOrShareChatRoom(dto, currentUserId);
            case GROUP -> handleGroupChatRoom(dto, image, currentUserId);
        };
    }

    private ChatRoomResponseDTO handleDirectOrShareChatRoom(ChatRoomRequestDTO dto, Long currentUserId) {
        Enum.ChatRoomType type = dto.getType();
        Long receiverId = dto.getReceiverId();
        Long sharePostId = dto.getSharePostId();

        // 자기 자신에게 메세지 전달 불가
        if (currentUserId.equals(receiverId)) {
            throw new IllegalArgumentException("자기 자신과는 채팅할 수 없습니다.");
        }

        // 🧍‍♂️ 유저 조회
        Member sender = memberRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("보내는 유저가 존재하지 않습니다."));

        Member receiver = memberRepository.findById(receiverId)
                .orElseThrow(() -> new EntityNotFoundException("받는 유저가 존재하지 않습니다."));

        // 📦 나눔 게시글 확인 (SHARE일 경우만)
        SharePost sharePost = null;
        if (type == Enum.ChatRoomType.SHARE) {
            if (sharePostId == null) {
                throw new IllegalArgumentException("나눔 채팅방은 sharePostId가 필요합니다.");
            }
            sharePost = sharePostRepository.findById(sharePostId)
                    .orElseThrow(() -> new EntityNotFoundException("해당 나눔글이 존재하지 않습니다."));
        }


        // 🔍 기존 채팅방 있는지 확인
        Optional<ChatRoom> optionalRoom =
                chatRoomRepository.findExistingDirectRoom(currentUserId, receiverId, type, sharePostId);
        if (optionalRoom.isPresent()) {
            return toResponseDTO(optionalRoom.get(), currentUserId);
        }

        // 🏗 새로운 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .type(type)
                .sharePost(sharePost)
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

        return toResponseDTO(chatRoom, currentUserId);
    }

    private ChatRoomResponseDTO handleGroupChatRoom(ChatRoomRequestDTO dto, MultipartFile image, Long currentUserId) {
        // 필수값 검증
        String roomName = dto.getChatRoomName();
        if (roomName == null || roomName.trim().isEmpty()) {
            throw new IllegalArgumentException("그룹 채팅방 이름은 필수입니다.");
        }

        // 현재 로그인한 사용자 조회
        Member creator = memberRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("사용자가 존재하지 않습니다."));

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

        return toResponseDTO(chatRoom, currentUserId);
    }

    // 채팅방 리스트 조회
    public List<ChatRoomResponseDTO> getChatRoomsForMember(Long memberId) {
        List<ChatRoom> chatRooms = chatRoomRepository.findAllByMemberIdWithMembers(memberId);

        return chatRooms.stream()
                .sorted(Comparator.comparing(
                        ChatRoom::getLastMessageSentAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .map(chatRoom -> toResponseDTO(chatRoom, memberId))
                .collect(Collectors.toList());
    }


    private ChatRoomResponseDTO toResponseDTO(ChatRoom chatRoom, Long currentUserId) {
        String otherNickname = null;
        String otherProfileImageUrl = null;

        // 현재 사용자
        Member currentUser = memberRepository.findById(currentUserId)
                .orElseThrow(() -> new IllegalArgumentException("해당 멤버를 찾을 수 없습니다."));

        // lastReadMessageId 조회
        ChatRoomMember chatRoomMember = chatRoomMemberRepository
                .findByChatRoomAndMember(chatRoom, currentUser)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 멤버가 아닙니다."));

        Long lastReadMessageId = chatRoomMember.getLastReadMessageId();

        int unreadCount;
        if (lastReadMessageId == null) {
            // 처음 입장한 경우 → 내가 보낸 걸 제외하고 전체 메시지 수
            unreadCount = messageRepository.countByChatRoomAndSenderNot(chatRoom, currentUser);
        } else {
            unreadCount = messageRepository.countByChatRoomAndIdGreaterThanAndSenderNot(
                    chatRoom, lastReadMessageId, currentUser);
        }

        if (chatRoom.getType() == Enum.ChatRoomType.DIRECT || chatRoom.getType() == Enum.ChatRoomType.SHARE) {
            // 채팅방의 모든 멤버 중 나와 다른 사람 찾기
            Member other = chatRoomMemberRepository.findByChatRoom(chatRoom).stream()
                    .map(ChatRoomMember::getMember)
                    .filter(member -> !member.getId().equals(currentUserId))
                    .findFirst()
                    .orElse(null);

            System.out.println("other : " + other);
            if (other != null) {
                otherNickname = other.getNickname();
                otherProfileImageUrl = other.getProfileImage();
            }
        }

        return ChatRoomResponseDTO.builder()
                .chatRoomId(chatRoom.getId())
                .type(chatRoom.getType())
                .chatRoomName(chatRoom.getChatRoomName()) // GROUP만 사용
                .imageUrl(chatRoom.getImageUrl())         // GROUP만 사용
                .lastMessage(chatRoom.getLastMessageContent())
                .lastSentAt(chatRoom.getLastMessageSentAt())
                .sharePostId(chatRoom.getSharePost() != null ? chatRoom.getSharePost().getId() : null)
                .otherNickname(otherNickname)                 // DIRECT, SHARE만 사용
                .otherProfileImageUrl(otherProfileImageUrl)   // DIRECT, SHARE만 사용
                .unreadCount(unreadCount)
                .build();
    }

    // 채팅방 수정
    @Transactional
    public void updateGroupChatRoom(Long chatRoomId, ChatRoomRequestDTO dto, MultipartFile image, Long memberId) {
        //채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("그룹 채팅방만 수정할 수 있습니다.");
        }

        // 로그인한 사용자 = 방장인지 확인
        ChatRoomMember member = chatRoomMemberRepository.findByChatRoomAndMemberId(chatRoom, memberId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방 멤버가 아닙니다."));

        if (!member.isAdmin()) {
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
    public void leaveChatRoom(Long chatRoomId, Long memberId) {

        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));


        // ChatRoomMember 조회 및 삭제
        ChatRoomMember member = chatRoomMemberRepository.findByChatRoomAndMemberId(chatRoom, memberId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방에 참여 중이지 않습니다."));

        chatRoomMemberRepository.delete(member);

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
    public void deleteGroupChatRoom(Long chatRoomId, Long memberId) {
        // 1. 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방이 존재하지 않습니다."));

        // 2. 그룹 채팅방인지 확인
        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("그룹 채팅방만 수정할 수 있습니다.");
        }

        // 3. 방장이 맞는지 확인
        ChatRoomMember admin = chatRoomMemberRepository
                .findByChatRoomIdAndMemberId(chatRoomId, memberId)
                .orElseThrow(() -> new IllegalArgumentException("해당 채팅방에 참여 중이지 않습니다."));

        if (!admin.isAdmin()) {
            throw new IllegalArgumentException("방장만 채팅방을 삭제할 수 있습니다.");
        }

        //
        chatRoomRepository.delete(chatRoom);
    }

    // 초대 코드 가져오기
    @Transactional
    public InviteLinkResponseDTO getInviteLink(Long chatRoomId, Long memberId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방을 찾을 수 없습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용할 수 있습니다.");
        }

        // (옵션) 요청자가 이 채팅방의 멤버인지 검증
        boolean isMember = chatRoomMemberRepository.existsByChatRoomIdAndMemberId(chatRoomId, memberId);
        if (!isMember) {
            throw new IllegalArgumentException("해당 채팅방에 속한 멤버만 초대 링크를 조회할 수 있습니다.");
        }


        String baseUrl = "http://localhost:8080/chat/invite/";
        String inviteCode = chatRoom.getInviteCode();

        return new InviteLinkResponseDTO(inviteCode, baseUrl + inviteCode);
    }

    // 초대 링크 정보 조회
    @Transactional
    public InviteCheckResponseDTO checkInviteAccess(String inviteCode, Long memberId) {
        ChatRoom chatRoom = chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("유효하지 않은 초대 코드입니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용할 수 있습니다.");
        }

        // 밴 여부 확인
        boolean isBanned = chatRoomBanRepository.existsByChatRoomIdAndBannedMemberId(chatRoom.getId(), memberId);
        if (isBanned) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }

        boolean isMember = chatRoomMemberRepository.existsByChatRoomIdAndMemberId(chatRoom.getId(), memberId);
        boolean requirePassword = (chatRoom.getPassword() != null && !chatRoom.getPassword().isBlank());


        return new InviteCheckResponseDTO(
                chatRoom.getChatRoomName(),
                isMember,
                isMember ? false : requirePassword // 이미 입장한 사람은 비밀번호 X
        );
    }

    // 비밀번호 확인 및 멤버 등록
    @Transactional
    public Long enterChatRoomViaInvite(String inviteCode, Long memberId, String password) {
        ChatRoom chatRoom = chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("초대 코드가 유효하지 않습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("초대 링크는 그룹 채팅방에서만 사용 가능합니다.");
        }

        // 밴 여부 확인
        boolean isBanned = chatRoomBanRepository.existsByChatRoomIdAndBannedMemberId(chatRoom.getId(), memberId);
        if (isBanned) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }

        // 이미 멤버인지 확인
        boolean isMember = chatRoomMemberRepository.existsByChatRoomIdAndMemberId(chatRoom.getId(), memberId);
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

        // ChatRoomMember 등록
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new EntityNotFoundException("회원 정보를 찾을 수 없습니다."));

        ChatRoomMember newMember = ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(member)
                .isAdmin(false)
                .build();

        chatRoomMemberRepository.save(newMember);

        return chatRoom.getId();
    }

    // 유효 유저 확인
    private Member validateMember(Long memberId, String error) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new EntityNotFoundException("보내는 유저가 존재하지 않습니다."));
    }
}
