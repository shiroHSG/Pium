package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.service.chat.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat-room")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 채팅방 생성
    @PostMapping
    public ResponseEntity<ChatRoomResponseDTO> getOrCreateChatRoom(
            @RequestBody ChatRoomRequestDTO dto,
//            @AuthenticationPrincipal CustomUserDetails userDetails
            Authentication authentication   //임시
    ) {
        Long memberId = (Long) authentication.getPrincipal();
        ChatRoomResponseDTO responseDTO = chatRoomService.getOrCreateChatRoom(dto, memberId);
        return ResponseEntity.ok(responseDTO);
    }

    // 채팅방 리스트 조회
    @GetMapping
    public ResponseEntity<List<ChatRoomResponseDTO>> getMyChatRooms(
//            @AuthenticationPrincipal CustomUserDetails userDetails
            Authentication authentication   //임시
    ) {
        Long memberId = (Long) authentication.getPrincipal();
        List<ChatRoomResponseDTO> chatRooms = chatRoomService.getChatRoomsForMember(memberId);
        return ResponseEntity.ok(chatRooms);
    }

}
