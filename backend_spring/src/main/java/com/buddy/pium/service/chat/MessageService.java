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
import java.util.ArrayList;
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
        // 1. 채팅방 존재 여부 확인
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 채팅방입니다."));

        // 2. 참여 여부 확인 + joinedAt 조회
        ChatRoomMember crm = chatRoomMemberRepository.findByChatRoomIdAndMemberId(chatRoomId, memberId)
                .orElseThrow(() -> new AccessDeniedException("이 채팅방에 접근할 수 없습니다."));
        LocalDateTime joinedAt = crm.getJoinedAt();

        List<Message> messages;

        // 3. 최신순으로 가져온 후 다시 역정렬 (오래된순으로 보여주기 위함)
        if (pivotId == null || direction.equals("latest")) {

            Long lastReadMessageId = crm.getLastReadMessageId();

            if (lastReadMessageId == null) {
                // 🔹 처음 입장 → joinedAt 이후 메시지 전체
                messages = messageRepository.findByChatRoomIdAndSentAtAfterOrderByIdAsc(chatRoomId, joinedAt);
            } else {
                // 🔹 이전 10개 + 이후 전체
                List<Message> before = messageRepository
                        .findTop10ByChatRoomIdAndIdLessThanAndSentAtAfterOrderByIdDesc(chatRoomId, lastReadMessageId, joinedAt);
                Collections.reverse(before);

                List<Message> after = messageRepository
                        .findByChatRoomIdAndIdGreaterThanEqualAndSentAtAfterOrderByIdAsc(chatRoomId, lastReadMessageId, joinedAt);

                messages = new ArrayList<>();
                messages.addAll(before);
                messages.addAll(after);
            }

            // 🔹 읽음 처리
            if (!messages.isEmpty()) {
                Long newLastReadMessageId = messages.get(messages.size() - 1).getId();

                if (crm.getLastReadMessageId() == null || crm.getLastReadMessageId() < newLastReadMessageId) {
                    crm.setLastReadMessageId(newLastReadMessageId);
                }
            }

        } else if ("prev".equals(direction)) {
            messages = messageRepository
                    .findTop100ByChatRoomIdAndIdLessThanAndSentAtAfterOrderByIdDesc(chatRoomId, pivotId, joinedAt);
            Collections.reverse(messages);

        } else {
            throw new IllegalArgumentException("direction은 latest, prev 중 하나여야 합니다.");
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
