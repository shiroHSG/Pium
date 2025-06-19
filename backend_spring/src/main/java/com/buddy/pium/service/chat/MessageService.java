package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomSummaryDto;
import com.buddy.pium.websocket.ChatWebSocketBroadcaster;
import com.buddy.pium.dto.chat.MessageResponseDto;
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
    private final ChatWebSocketBroadcaster chatWebSocketBroadcaster;

    // 메세지 전송
    @Transactional
    public MessageResponseDto sendMessage(Long chatRoomId, Member sender, String content) {
        System.out.println("message 전송 service");
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
        chatRoom.setLastMessageSentAt(message.getSentAt());
        chatRoomRepository.save(chatRoom);

        // 보낸 사람은 즉시 읽음 처리
        senderMember.setLastReadMessageId(message.getId());
        chatRoomMemberRepository.save(senderMember);

        // 참여자별 summary(채팅방) 전송 (보낸 사람 제외)
        List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoomId(chatRoomId);
        for (ChatRoomMember crm : members) {
            Member target = crm.getMember();

            if (target.equals(sender)) continue; // 👈 객체 비교로 바뀜 (더 안전하고 직관적)

            int unreadCount = calculateUnreadCount(message, target); // ✅ Member 객체 그대로 전달

            ChatRoomSummaryDto summary = ChatRoomSummaryDto.builder()
                    .chatRoomId(chatRoomId)
                    .lastMessage(content)
                    .lastSentAt(message.getSentAt())
                    .unreadCount(unreadCount)
                    .build();

//            chatWebSocketBroadcaster.broadcastChatSummary(target.getId(), summary);

            // ✅ 사이드바 뱃지용 전체 unreadCount도 추가로 전송
            chatWebSocketBroadcaster.broadcastUnreadCount(target.getId());
        }

        // 실시간 메시지 broadcast
        MessageResponseDto dto = toDTO(message, sender);
        chatWebSocketBroadcaster.broadcastMessage(chatRoomId, dto);

        return dto;
    }

    // 메세지 조회
    @Transactional
    public List<MessageResponseDto> getMessages(Long chatRoomId, Member member, Long pivotId, String direction) {
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);
        ChatRoomMember chatRoomMember = chatRoomMemberService.validateChatRoomMember(chatRoom, member);
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

                    // summary 전송 → 대상: 본인
                    int unreadCount = calculateUnreadCount(messages.get(messages.size() - 1), member);

                    ChatRoomSummaryDto summary = ChatRoomSummaryDto.builder()
                            .chatRoomId(chatRoomId)
                            .lastMessage(messages.get(messages.size() - 1).getContent())
                            .lastSentAt(messages.get(messages.size() - 1).getSentAt())
                            .unreadCount(unreadCount)
                            .build();

//                    chatWebSocketBroadcaster.broadcastChatSummary(member.getId(), summary);

                    // 읽음 브로드캐스트 (읽은 사람 → 같은 방의 다른 사람들에게)
                    List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoomId(chatRoomId);
                    for (ChatRoomMember crm : members) {
                        Member other = crm.getMember();
                        if (other.equals(member)) continue; // 본인은 제외

                        chatWebSocketBroadcaster.broadcastReadStatus(
                                chatRoomId,
                                member.getId(),              // 읽은 사람 ID
                                newLastReadMessageId         // 마지막으로 읽은 메시지 ID
                        );
                    }

                    chatWebSocketBroadcaster.broadcastUnreadCount(member.getId());
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
                .map(message -> toDTO(message, member))
                .collect(Collectors.toList());
    }

    private MessageResponseDto toDTO(Message message, Member sender) {
        int unreadCount = calculateUnreadCount(message, sender);

        return MessageResponseDto.builder()
                .messageId(message.getId())
                .senderId(message.getSender().getId())
                .senderNickname(message.getSender().getNickname())
                .senderProfileImageUrl(message.getSender().getProfileImageUrl())
                .content(message.getContent())
                .sentAt(message.getSentAt())
                .unreadCount(unreadCount)
                .build();
    }

    public int calculateUnreadCount(Message message, Member sender) {
        return chatRoomMemberRepository.countUnreadMembers(
                message.getChatRoom().getId(),
                message.getId(),
                sender.getId()
        );
    }
}
