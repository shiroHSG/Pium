package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.MessageRequestDTO;
import com.buddy.pium.dto.chat.MessageResponseDTO;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.service.chat.ChatRoomMemberService;
import com.buddy.pium.service.chat.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat-rooms")
public class MessageController {

    private final MessageService messageService;
    private final ChatRoomMemberService chatRoomMemberService;

    // 메세지 전송
    @PostMapping("/{chatRoomId}/messages")
    public ResponseEntity<MessageResponseDTO> sendMessage(
            @PathVariable Long chatRoomId,
            @RequestBody MessageRequestDTO dto,
            Authentication authentication   //임시
    ) {
        System.out.println("메세지 전송 : " + authentication);
        Long senderId = (Long) authentication.getPrincipal();

        MessageResponseDTO response = messageService.sendMessage(
                chatRoomId,
                senderId,
                dto.getContent()
        );

        return ResponseEntity.ok(response);
    }

    // 메세지 조회 pivotId : 기준 메시지 ID, direction : prev, latest
    // 메세지 조회와 동시에 읽음 처리도 여기서
    @GetMapping("/{chatRoomId}/messages")
    public ResponseEntity<List<MessageResponseDTO>> getMessages(
            @PathVariable Long chatRoomId,
            @RequestParam(required = false) Long pivotId,
            @RequestParam String direction,
            Authentication authentication   //임시
    ) {
        Long memberId = (Long) authentication.getPrincipal();

        List<MessageResponseDTO> messages = messageService.getMessages(chatRoomId, memberId, pivotId, direction);
        return ResponseEntity.ok(messages);
    }

}
