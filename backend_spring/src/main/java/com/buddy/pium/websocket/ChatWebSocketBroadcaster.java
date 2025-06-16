package com.buddy.pium.websocket;

import com.buddy.pium.dto.chat.ChatRoomSummaryDto;
import com.buddy.pium.dto.chat.MessageResponseDto;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * DestinationVariable vs PathVariable
 * webSocket/STOMP         http
 * 웹소켓 경로의 변수         http url 경로의 변수
 */

@Component
@RequiredArgsConstructor
public class ChatWebSocketBroadcaster {
    private final SimpMessagingTemplate messagingTemplate;

    // 채팅방 내부 메세지 브로드캐스트
    public void broadcastMessage(Long chatRoomId, MessageResponseDto dto) {
        messagingTemplate.convertAndSend("/sub/chatroom/" + chatRoomId, dto);
    }

    // 채팅방 읽음 상태 브로드캐스트
    public void broadcastReadStatus(Long chatRoomId, Long readerId, Long lastReadMessageId) {
        Map<String, Object> payload = Map.of(
                "chatRoomId", chatRoomId,
                "readerId", readerId,
                "lastReadMessageId", lastReadMessageId
        );
        messagingTemplate.convertAndSend("/sub/chatroom/" + chatRoomId + "/read", payload);
    }

    // 3. 채팅방 요약 정보 (사이드탭 / 리스트 갱신용)
    public void broadcastChatSummary(Long memberId, ChatRoomSummaryDto summaryDTO) {
        messagingTemplate.convertAndSend("/sub/member/" + memberId + "/summary", summaryDTO);
    }
}
