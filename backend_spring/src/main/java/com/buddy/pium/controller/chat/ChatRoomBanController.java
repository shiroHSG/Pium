package com.buddy.pium.controller.chat;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.chat.ChatRoomBanService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chatroom/{chatRoomId}/member/{memberId}")
public class ChatRoomBanController {

    private final ChatRoomBanService chatRoomBanService;

    @PostMapping("ban")
    public ResponseEntity<?> banMember(
            @PathVariable Long chatRoomId,
            @PathVariable Long memberId,
            @CurrentMember Member member
    ) {
        chatRoomBanService.banMember(chatRoomId, member, memberId);
        return ResponseEntity.ok(Map.of("message", "사용자 제한 등록 완료"));
    }
}
