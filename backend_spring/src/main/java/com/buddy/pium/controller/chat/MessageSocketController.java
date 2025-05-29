package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomSummaryDTO;
import com.buddy.pium.dto.chat.MessageRequestDTO;
import com.buddy.pium.dto.chat.MessageResponseDTO;
import com.buddy.pium.dto.chat.ReadMessageDTO;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.service.chat.MessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.List;

/**
 * DestinationVariable vs PathVariable
 * webSocket/STOMP         http
 * 웹소켓 경로의 변수         http url 경로의 변수
 */

@Slf4j
@Controller
@RequiredArgsConstructor
public class MessageSocketController {

    private final SimpMessagingTemplate messagingTemplate;
    private final MessageService messageService;

    // 메세지 전송 처리
    // 클라이언트 요청 주소 pub/chat-rooms~
    @MessageMapping("/chat-rooms/{chatRoomId}/send")
    public void sendMessage(@DestinationVariable Long chatRoomId,
                            MessageRequestDTO dto) {

        // db 저장
        MessageResponseDTO savedMessage = messageService.saveMessage(chatRoomId, dto.getSenderId(), dto.getContent());

        // 메세지 실시간 전송
        messagingTemplate.convertAndSend("/sub/chat-rooms/" + chatRoomId, savedMessage);

        // 요약 정보 전송
        List<ChatRoomMember> participants = messageService.getParticipants(chatRoomId);
        for (ChatRoomMember member : participants) {
            ChatRoomSummaryDTO summary = messageService.getRoomSummaryForMember(chatRoomId, member.getMember().getId());
            messagingTemplate.convertAndSend("/sub/members" + member.getMember().getId() + "/summary", summary);
        }
    }

    // 채팅방 접속시 메세지 읽음 처리
    @MessageMapping("/chat-rooms/{chatRoomId}/read")
    public void readMessages(@DestinationVariable Long chatRoomId,
                             ReadMessageDTO dto) {
        messageService.markMessagesAsRead(chatRoomId, dto.getReaderId(), dto.getLastReadMessageId());

        messagingTemplate.convertAndSend("/sub/chat-rooms/" + chatRoomId + "/read", dto);
    }
}
