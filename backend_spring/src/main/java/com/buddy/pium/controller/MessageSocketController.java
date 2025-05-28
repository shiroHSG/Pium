package com.buddy.pium.controller;

import com.buddy.pium.service.chat.MessageService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.SendTo;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

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

    // 수동 브로드캐스트 예제
    @MessageMapping("/broadcast")
    public void broadcast(String message) {
        log.info("📢 브로드캐스트: {}", message);
        messagingTemplate.convertAndSend("/sub/broadcast", "📣 서버 브로드캐스트: " + message);
    }

    // 메세지 전송 처리
    @MessageMapping("/chat-rooms/{chatRoomId}/send")
    public void sendMessage(@DestinationVariable Long chatRoomId,
                            MessageRequestDTO dto) {
        log.info("📢 브로드캐스트: {}", message);
        messagingTemplate.convertAndSend("/sub/broadcast", "📣 서버 브로드캐스트: " + message);
    }
}
