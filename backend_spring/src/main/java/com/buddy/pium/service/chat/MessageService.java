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
import com.buddy.pium.service.common.MemberService;
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

    private final ChatRoomService chatRoomService;
    private final ChatRoomMemberService chatRoomMemberService;
    private final MemberService memberService;

    // 메세지 전송
    @Transactional
    public MessageResponseDTO sendMessage(Long chatRoomId, Member sender, String content) {
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);
        ChatRoomMember senderMember = chatRoomMemberService.validateChatRoomMember(chatRoom, sender);

        Message message = Message.builder()
                .chatRoom(chatRoom)
                .sender(sender)
                .content(content)
                .build();

        messageRepository.save(message);

        // 채팅방 최신 메시지 갱신
        chatRoom.setLastMessageContent(content);
        chatRoom.setLastMessageSentAt(LocalDateTime.now());
        chatRoomRepository.save(chatRoom);

        // 마지막으로 읽은 메시지를 현재 메시지로 갱신
        senderMember.setLastReadMessageId(message.getId());
        chatRoomMemberRepository.save(senderMember);

        return toDTO(message, sender);
    }

    // 메세지 조회
    @Transactional
    public List<MessageResponseDTO> getMessages(Long chatRoomId, Member sender, Long pivotId, String direction) {
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);
        ChatRoomMember chatRoomMember = chatRoomMemberService.validateChatRoomMember(chatRoom, sender);
        LocalDateTime joinedAt = chatRoomMember.getJoinedAt();

        List<Message> messages;

        // 최신순으로 가져온 후 다시 역정렬 (오래된순으로 보여주기 위함)
        if (pivotId == null || direction.equals("latest")) {

            Long lastReadMessageId = chatRoomMember.getLastReadMessageId();

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

                if (chatRoomMember.getLastReadMessageId() == null || chatRoomMember.getLastReadMessageId() < newLastReadMessageId) {
                    chatRoomMember.setLastReadMessageId(newLastReadMessageId);
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
                .map(message -> toDTO(message, sender))
                .collect(Collectors.toList());
    }

    private MessageResponseDTO toDTO(Message message, Member sender) {
        int unreadCount = chatRoomMemberRepository.countUnreadMembers(
                message.getChatRoom().getId(),
                message.getId(),
                sender.getId()  // 👈 이건 쿼리에서 본인 제외에 필요
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
