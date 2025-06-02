package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.SharePost;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.SharePostRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
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

    //direct(개인, 나눔) dto 전달
    public ChatRoomResponseDTO getOrCreateChatRoom(ChatRoomRequestDTO dto, Long currentUserId ) {
        Enum.ChatRoomType type = dto.getType();

        return switch (type) {
            case DIRECT, SHARE -> handleDirectOrShareChatRoom(dto, currentUserId);
            case GROUP -> handleGroupChatRoom(dto, currentUserId);
        };
    }

    private ChatRoomResponseDTO handleDirectOrShareChatRoom(ChatRoomRequestDTO dto, Long currentUserId) {
        Enum.ChatRoomType type = dto.getType();
        Long receiverId = dto.getReceiverId();
        Long sharePostId = dto.getSharePostId();

        // 🔐 자기 자신에게 메시지 보낼 수 없음
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

    private ChatRoomResponseDTO handleGroupChatRoom(ChatRoomRequestDTO dto, Long currentUserId) {
        // 필수값 검증
        String roomName = dto.getChatRoomName();
        if (roomName == null || roomName.trim().isEmpty()) {
            throw new IllegalArgumentException("그룹 채팅방 이름은 필수입니다.");
        }

        // 현재 로그인한 사용자 조회
        Member creator = memberRepository.findById(currentUserId)
                .orElseThrow(() -> new EntityNotFoundException("사용자가 존재하지 않습니다."));

        // 채팅방 생성
        ChatRoom chatRoom = ChatRoom.builder()
                .type(Enum.ChatRoomType.GROUP)
                .chatRoomName(roomName)
                .password(dto.getPassword())       // optional
                .imageUrl(dto.getImageUrl())       // optional
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
        List<ChatRoomMember> myChatRoomMembers =
                chatRoomMemberRepository.findByMemberId(memberId);

        return myChatRoomMembers.stream()
                .map(ChatRoomMember::getChatRoom)
                .distinct()
                .sorted(Comparator.comparing(
                        ChatRoom::getLastMessageSentAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .map(chatRoom -> toResponseDTO(chatRoom, memberId)) // 정렬 후 DTO 변환
                .collect(Collectors.toList());
    }

    private ChatRoomResponseDTO toResponseDTO(ChatRoom chatRoom, Long currentUserId) {
        String otherNickname = null;
        String otherProfileImageUrl = null;

        if (chatRoom.getType() == Enum.ChatRoomType.DIRECT || chatRoom.getType() == Enum.ChatRoomType.SHARE) {
            // 채팅방의 모든 멤버 중 나와 다른 사람 찾기
            Member other = chatRoom.getChatRoomMembers().stream()
                    .map(ChatRoomMember::getMember)
                    .filter(member -> !member.getId().equals(currentUserId))
                    .findFirst()
                    .orElse(null);

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
                .build();
    }

}
