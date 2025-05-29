package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.service.chat.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat-room")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 채팅방 생성
    @PostMapping
    public ResponseEntity<ChatRoomResponseDTO> createChatRoom(
            @RequestBody ChatRoomRequestDTO requestDto,
            @RequestHeader("X-USER-ID") Long senderId
    ) {
        ChatRoomResponseDTO response = chatRoomService.createChatRoom(requestDto, senderId);
        return ResponseEntity.ok(response);
    }
}
