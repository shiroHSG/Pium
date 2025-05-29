package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
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
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final SharePostRepository sharePostRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public ChatRoomResponseDTO createChatRoom(ChatRoomRequestDTO dto, Long senderId) {
        if (dto.getIsGroup() == null) {
            throw new IllegalArgumentException("isGroup 필드는 필수입니다.");
        }

        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new EntityNotFoundException("사용자를 찾을 수 없습니다."));

        if (dto.getIsGroup()) {
            // 단체방
            return toResponseDTO(createGroupChatRoom(dto, sender), senderId);
        } else {
            // 1:1
            if (dto.getReceiverId() == null) {
                throw new IllegalArgumentException("1:1 채팅에는 receiverId가 필요합니다.");
            }

            Member receiver = memberRepository.findById(dto.getReceiverId())
                    .orElseThrow(() -> new EntityNotFoundException("상대방을 찾을 수 없습니다."));

            if (dto.getPostId() != null) {
                return toResponseDTO(getOrCreateShareChatRoom(sender, receiver, dto.getPostId()), senderId);
            } else {
                return toResponseDTO(getOrCreateDirectChatRoom(sender, receiver), senderId);
            }
        }
    }

    private ChatRoomResponseDTO toResponseDTO(ChatRoom chatRoom, Long currentUserId) {
        String chatRoomName;

        if (chatRoom.isGroup()) {
            chatRoomName = chatRoom.getChatRoomName();
        } else {
            List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoom(chatRoom);
            Member other = members.stream()
                    .map(ChatRoomMember::getMember)
                    .filter(m -> !m.getId().equals(currentUserId))
                    .findFirst()
                    .orElse(null);
            chatRoomName = (other != null) ? other.getNickname() : "(알 수 없음)";
        }

        return ChatRoomResponseDTO.builder()
                .chatRoomId(chatRoom.getId())
                .isGroup(chatRoom.isGroup())
                .chatRoomName(chatRoomName)
                .lastMessage(chatRoom.getLastMessageContent())
                .lastSentAt(chatRoom.getLastMessageSentAt())
                .build();
    }

    @Transactional
    public ChatRoom createGroupChatRoom(ChatRoomRequestDTO dto, Member creator) {
        ChatRoom chatRoom = ChatRoom.builder()
                .isGroup(true)
                .chatRoomName(dto.getChatRoomName())
                .password(dto.getPassword())
                .imageUrl(dto.getImageUrl())
                .createdAt(LocalDateTime.now())
                .build();
        chatRoomRepository.save(chatRoom);

        ChatRoomMember creatorMember = ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(creator)
                .isAdmin(true)
                .joinedAt(LocalDateTime.now())
                .build();
        chatRoomMemberRepository.save(creatorMember);

        return chatRoom;
    }

    //dm 채팅방
    @Transactional
    public ChatRoom getOrCreateDirectChatRoom(Member sender, Member receiver) {
        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("자기 자신과는 채팅할 수 없습니다.");
        }

        Optional<ChatRoom> existing = chatRoomRepository.findDirectChatRoomBetween(
                sender.getId(), receiver.getId()
        );

        if (existing.isPresent()) return existing.get();

        ChatRoom chatRoom = ChatRoom.builder()
                .isGroup(false)
                .createdAt(LocalDateTime.now())
                .build();
        chatRoomRepository.save(chatRoom);

        chatRoomMemberRepository.saveAll(List.of(
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(sender)
                        .isAdmin(false)
                        .joinedAt(LocalDateTime.now())
                        .build(),
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(receiver)
                        .isAdmin(false)
                        .joinedAt(LocalDateTime.now())
                        .build()
        ));

        return chatRoom;
    }

    // 나눔 채팅방
    @Transactional
    public ChatRoom getOrCreateShareChatRoom(Member sender, Member receiver, Long postId) {
        if (sender.getId().equals(receiver.getId())) {
            throw new IllegalArgumentException("자기 자신과는 채팅할 수 없습니다.");
        }

        SharePost post = sharePostRepository.findById(postId)
                .orElseThrow(() -> new EntityNotFoundException("해당 나눔 게시글이 존재하지 않습니다."));

        Optional<ChatRoom> existing = chatRoomRepository.findSharedChatRoomWithTwoMembers(
                sender.getId(), receiver.getId(), postId
        );

        if (existing.isPresent()) return existing.get();

        ChatRoom chatRoom = ChatRoom.builder()
                .isGroup(false)
                .sharePost(post)
                .createdAt(LocalDateTime.now())
                .build();
        chatRoomRepository.save(chatRoom);

        chatRoomMemberRepository.saveAll(List.of(
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(sender)
                        .isAdmin(false)
                        .joinedAt(LocalDateTime.now())
                        .build(),
                ChatRoomMember.builder()
                        .chatRoom(chatRoom)
                        .member(receiver)
                        .isAdmin(false)
                        .joinedAt(LocalDateTime.now())
                        .build()
        ));

        return chatRoom;
    }


}
