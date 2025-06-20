package com.buddy.pium.controller.chat;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.chat.MessageRequestDto;
import com.buddy.pium.dto.chat.MessageResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.chat.MessageService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chatroom/{chatRoomId}/messages")
public class MessageController {

    private final MessageService messageService;

    // 메세지 전송
    @PostMapping
    public ResponseEntity<MessageResponseDto> sendMessage(
            @PathVariable Long chatRoomId,
            @RequestBody MessageRequestDto dto,
            @CurrentMember Member member
    ) {
        System.out.println();
        MessageResponseDto response = messageService.sendMessage(chatRoomId, member, dto.getContent());
        return ResponseEntity.ok(response);
    }

    // 메세지 조회 pivotId : 기준 메시지 ID, direction : latest, prev
    // 메세지를 불러올때 가장 처음온 메세지 id를 pivotId로 지정
    // 메세지 조회와 동시에 읽음 처리도 여기서
    @GetMapping
    public ResponseEntity<List<MessageResponseDto>> getMessages(
            @PathVariable Long chatRoomId,
            @RequestParam(name = "pivotId", required = false) Long pivotId,
            @RequestParam(name = "direction") String direction,
            @CurrentMember Member member
    ) {
        List<MessageResponseDto> messages = messageService.getMessages(chatRoomId, member, pivotId, direction);
        return ResponseEntity.ok(messages);
    }
}
