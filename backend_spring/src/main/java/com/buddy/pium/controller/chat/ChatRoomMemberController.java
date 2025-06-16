package com.buddy.pium.controller.chat;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.chat.ChatRoomMemberResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.chat.ChatRoomMemberService;
import com.buddy.pium.service.chat.ChatRoomService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RequiredArgsConstructor
@RestController
@RequestMapping("/api/chatroom/{chatRoomId}/members")
public class ChatRoomMemberController {

    private final ChatRoomService chatRoomService;
    private final ChatRoomMemberService chatRoomMemberService;

    // ✅ 채팅방 멤버 조회
    @GetMapping
    public ResponseEntity<?> getChatRoomMembers(
            @PathVariable Long chatRoomId,
            @CurrentMember Member member
    ) {
        try {
            ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);  // 추가
            List<ChatRoomMemberResponseDTO> members =
                    chatRoomMemberService.getChatRoomMembers(chatRoom, member); // 변경
            return ResponseEntity.ok(members);
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // ✅ 관리자 위임
    @PatchMapping("/{newAdminId}/delegate")
    public ResponseEntity<?> delegateAdmin(
            @PathVariable Long chatRoomId,
            @PathVariable Long newAdminId,
            @CurrentMember Member member
    ) {
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId); // 추가
        chatRoomMemberService.delegateAdmin(chatRoom, member, newAdminId); // 변경
        return ResponseEntity.ok(Map.of("message", "관리자 권한이 성공적으로 위임되었습니다."));
    }
}
