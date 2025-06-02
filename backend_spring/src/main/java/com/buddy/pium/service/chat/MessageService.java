//package com.buddy.pium.service.chat;
//
//import com.buddy.pium.dto.chat.ChatRoomSummaryDTO;
//import com.buddy.pium.dto.chat.MessageResponseDTO;
//import com.buddy.pium.entity.chat.ChatRoom;
//import com.buddy.pium.entity.chat.ChatRoomMember;
//import com.buddy.pium.entity.chat.Message;
//import com.buddy.pium.entity.common.Member;
//import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
//import com.buddy.pium.repository.chat.ChatRoomRepository;
//import com.buddy.pium.repository.chat.MessageRepository;
//import com.buddy.pium.repository.common.MemberRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//import java.util.List;
//import java.util.Locale;
//
//@Service
//@RequiredArgsConstructor
//public class MessageService {
//
//    private final ChatRoomRepository chatRoomRepository;
//    private final MemberRepository memberRepository;
//    private final MessageRepository messageRepository;
//    private final ChatRoomMemberRepository chatRoomMemberRepository;
//
//    // 메시지 저장
//    public MessageResponseDTO saveMessage(Long chatRoomId, Long senderId, String content) {
//        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
//                .orElseThrow(() -> new IllegalArgumentException("채팅방이 존재하지 않습니다."));
//
//        Member sender = memberRepository.findById(senderId)
//                .orElseThrow(() -> new IllegalArgumentException("사용자가 존재하지 않습니다."));
//
//        Message message = Message.builder()
//                .chatRoom(chatRoom)
//                .sender(sender)
//                .content(content)
//                .build();
//
//        Message saved = messageRepository.save(message);
//
//        return new MessageResponseDTO(
//                saved.getId(),
//                sender.getId(),
//                saved.getContent(),
//                saved.getSentAt()
//        );
//    }
//
//    // 채팅방 참여자 가져오기
//    public List<ChatRoomMember> getParticipants(Long chatRoomId) {
//        return chatRoomMemberRepository.findByChatRoomId(chatRoomId);
//    }
//
//    public ChatRoomSummaryDTO getRoomSummaryForMember(Long chatRoomId, Long memberId) {
//        // 1. 해당 사용자의 마지막 읽은 메시지 ID 조회
//        Long lastReadMessageId = chatRoomMemberRepository.findLastReadMessageId(chatRoomId, memberId);
//
//        // 2. 읽지 않은 메시지 수 계산 (상대방이 보낸 것만)
//        int unreadCount = (lastReadMessageId != null)
//                ? messageRepository.countUnreadMessages(chatRoomId, memberId, lastReadMessageId)
//                : messageRepository.countAllUnreadMessagesExceptSender(chatRoomId, memberId);
//
//        // 3. 마지막 메시지 조회
//        Message lastMessage = messageRepository.findLastMessage(chatRoomId);
//
//        return new ChatRoomSummaryDTO(
//                chatRoomId,
//                lastMessage != null ? lastMessage.getContent() : null,
//                unreadCount,
//                lastMessage != null ? lastMessage.getSentAt() : null
//        );
//    }
//
//    // 읽음 처리
//    public void markMessagesAsRead(Long chatRoomId, Long memberId, Long lastReadMessageId) {
//        messageRepository.markAsReadUpTo(chatRoomId, memberId, lastReadMessageId);
//    }
//}
