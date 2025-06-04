package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDTO;
import com.buddy.pium.dto.chat.ChatRoomResponseDTO;
import com.buddy.pium.service.chat.ChatRoomService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chat-room")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 채팅방 생성
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> getOrCreateChatRoom(
            @RequestPart("chatRoomData") String chatRoomDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            Authentication authentication   //임시
//            @AuthenticationPrincipal CustomUserDetails userDetails
    ) {
        try {
            Long memberId = (Long) authentication.getPrincipal();

            ObjectMapper mapper = new ObjectMapper();
            ChatRoomRequestDTO dto = mapper.readValue(chatRoomDataJson, ChatRoomRequestDTO.class);

            ChatRoomResponseDTO responseDTO = chatRoomService.getOrCreateChatRoom(dto, image, memberId);

            return ResponseEntity.ok(responseDTO);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
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
