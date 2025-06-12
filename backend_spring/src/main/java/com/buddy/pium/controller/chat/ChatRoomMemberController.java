package com.buddy.pium.controller.chat;

import com.buddy.pium.dto.chat.ChatRoomMemberResponseDTO;
import com.buddy.pium.service.chat.ChatRoomMemberService;
import com.buddy.pium.service.chat.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chatroom")
public class ChatRoomMemberController {

    private final ChatRoomMemberService chatRoomMemberService;

    @GetMapping("/{chatRoomId}/members")
    public ResponseEntity<?> getChatRoomMembers(
            @PathVariable Long chatRoomId,
            Authentication authentication
    ) {
        try {
            Long currentMemberId = (Long) authentication.getPrincipal();
            List<ChatRoomMemberResponseDTO> members = chatRoomMemberService.getChatRoomMembers(chatRoomId, currentMemberId);
            return ResponseEntity.ok(members);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("error", e.getMessage()));
        }
    }

    // 관리자 위임
    @PatchMapping("/{chatRoomId}/members/{newAdminId}/delegate")
    public ResponseEntity<?> delegateAdmin(
            @PathVariable Long chatRoomId,
            @PathVariable Long newAdminId,
            Authentication authentication
    ) {
        Long currentUserId = (Long) authentication.getPrincipal();

        chatRoomMemberService.delegateAdmin(chatRoomId, currentUserId, newAdminId);

        return ResponseEntity.ok(Map.of("message", "관리자 권한이 성공적으로 위임되었습니다."));
    }

}
