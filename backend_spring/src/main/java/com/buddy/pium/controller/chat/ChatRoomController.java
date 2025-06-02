package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.service.chat.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat-room")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 채팅방 생성
    @PostMapping
    public ResponseEntity<ChatRoomResponseDTO> getOrCreateChatRoom(
            @RequestBody ChatRoomRequestDTO dto,
            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        ChatRoomResponseDTO responseDTO = chatRoomService.getOrCreateChatRoom(dto, senderId);
        return ResponseEntity.ok(responseDTO);
    }
}
