package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.MessageResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Message;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.repository.chat.MessageRepository;
import com.buddy.pium.repository.common.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MessageService {

    private final ChatRoomRepository chatRoomRepository;
    private final MemberRepository memberRepository;
    private final MessageRepository messageRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;

    // 메세지 전송
    public MessageResponseDTO sendMessage(Long chatRoomId, Long senderId, String content) {
        // 채팅방 조회
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 채팅방입니다."));
        // 멤버 조회
        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        Message message = Message.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .content(content)
                .build();

        messageRepository.save(message);

        // 채팅방 최신 메시지 갱신
        chatRoom.setLastMessageContent(content);
        chatRoom.setLastMessageSentAt(LocalDateTime.now());

        return toDTO(message, senderId);
    }

    // 메세지 조회
    @Transactional
    public List<MessageResponseDTO> getMessages(
            Long chatRoomId,
            Long memberId,
            Long pivotId,
            String direction
    ) {
        // 채팅방 존재 여부 확인
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 채팅방입니다."));

        // 사용자가 채팅방 멤버인지 확인
        boolean isMember = chatRoomMemberRepository.existsByChatRoomIdAndMemberId(chatRoomId, memberId);
        if (!isMember) {
            throw new AccessDeniedException("이 채팅방에 접근할 수 없습니다.");
        }

        // 3. 메시지 조회 (lastMessageId 보다 작은 메시지 중 최신순)
        List<Message> messages;

        // 4. 최신순으로 가져온 후 다시 역정렬 (오래된순으로 보여주기 위함)
        if (pivotId == null || direction.equals("latest")) {

            // 1. 마지막 읽은 메시지 ID 조회
            Long lastReadMessageId = chatRoomMemberRepository
                    .findLastReadMessageId(chatRoomId, memberId); // custom query 필요

            // 2. 이후 메시지 모두 조회 (오래된 순 정렬)
            if (lastReadMessageId == null) {
                // 처음 입장한 경우 → 최근 100개
                messages = messageRepository.findTop100ByChatRoomIdOrderByIdDesc(chatRoomId);
                Collections.reverse(messages);
            } else {
                messages = messageRepository.findByChatRoomIdAndIdGreaterThanOrderByIdAsc(chatRoomId, lastReadMessageId);
            }

            // 3. 읽음 처리 (조회된 메시지 중 마지막 메시지 ID로 갱신)
            if (!messages.isEmpty()) {
                Long newLastReadMessageId = messages.get(messages.size() - 1).getId();
                ChatRoomMember crm = chatRoomMemberRepository
                        .findByChatRoomIdAndMemberId(chatRoomId, memberId)
                        .orElseThrow(() -> new RuntimeException("참여자가 아님"));

                if (crm.getLastReadMessageId() == null || crm.getLastReadMessageId() < newLastReadMessageId) {
                    crm.setLastReadMessageId(newLastReadMessageId);
                }
            }
        } else if ("prev".equals(direction)) {
            messages = messageRepository.findTop100ByChatRoomIdAndIdLessThanOrderByIdDesc(chatRoomId, pivotId);
            Collections.reverse(messages);
        } else {
            throw new IllegalArgumentException("direction은 latest, prev, next 중 하나여야 합니다.");
        }

        return messages.stream()
                .map(message -> toDTO(message, memberId))
                .collect(Collectors.toList());
    }

    private MessageResponseDTO toDTO(Message message, Long currentMemberId) {
        int unreadCount = chatRoomMemberRepository.countUnreadMembers(
                message.getChatRoom().getId(),
                message.getId(),
                currentMemberId  // 👈 이건 쿼리에서 본인 제외에 필요
        );

        return MessageResponseDTO.builder()
                .messageId(message.getId())
                .senderId(message.getSender().getId())
                .senderNickname(message.getSender().getNickname())
                .content(message.getContent())
                .sentAt(message.getSentAt())
                .unreadCount(unreadCount)
                .build();
    }
}
