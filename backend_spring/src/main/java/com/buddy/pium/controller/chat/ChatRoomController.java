package com.buddy.pium.controller.chat;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.chat.ChatRoomRequestDto;
import com.buddy.pium.dto.chat.ChatRoomResponseDto;
import com.buddy.pium.dto.chat.InviteCheckResponseDto;
import com.buddy.pium.dto.chat.InviteLinkResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.chat.ChatRoomService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/chatroom")
public class ChatRoomController {

    private final ChatRoomService chatRoomService;

    // 기존 채팅방 반환 또는 생성
    // DIRECT : type, receiverId
    // SHARE : type, receiverId, shareId
    // GROUP : type, password, chatRoomName
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> getOrCreateChatRoom(
            @RequestPart("chatRoomData") String chatRoomDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            ChatRoomRequestDto dto = mapper.readValue(chatRoomDataJson, ChatRoomRequestDto.class);

            ChatRoomResponseDto responseDTO = chatRoomService.getOrCreateChatRoom(dto, image, member);

            return ResponseEntity.ok(responseDTO);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 채팅방 리스트 조회
    @GetMapping
    public ResponseEntity<List<ChatRoomResponseDto>> getMyChatRooms(
            @CurrentMember Member member
    ) {
        System.out.println("채팅방리스트 조회 controller");
        List<ChatRoomResponseDto> chatRooms = chatRoomService.getChatRoomsForMember(member);
        return ResponseEntity.ok(chatRooms);
    }

    // 채팅방 수정
    @PatchMapping(value = "{chatRoomId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateGroupChatRoom(
            @PathVariable Long chatRoomId,
            @RequestPart("chatRoomData") String chatRoomDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            ChatRoomRequestDto dto = mapper.readValue(chatRoomDataJson, ChatRoomRequestDto.class);

            chatRoomService.updateGroupChatRoom(chatRoomId, dto, image, member);
            return ResponseEntity.ok(Map.of("message", "채팅방 수정 완료"));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 채팅방 나가기
    @DeleteMapping("{chatRoomId}/leave")
    public ResponseEntity<?> leaveChatRoom(
            @PathVariable Long chatRoomId,
            @CurrentMember Member member
    ) {
        try {
            chatRoomService.leaveChatRoom(chatRoomId, member);

            return ResponseEntity.ok(Map.of("message", "채팅방을 나갔습니다."));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 채팅방 삭제(방장)
    @DeleteMapping("/{chatRoomId}")
    public ResponseEntity<?> deleteGroupChatRoom(
            @PathVariable Long chatRoomId,
            @CurrentMember Member member
    ) {
        try {
            chatRoomService.deleteGroupChatRoom(chatRoomId, member);
            return ResponseEntity.ok(Map.of("message", "채팅방이 성공적으로 삭제되었습니다."));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 초대 링크 조회
    @GetMapping("{chatRoomId}/invite-link")
    public ResponseEntity<?> getInviteLink(
            @PathVariable Long chatRoomId,
            @CurrentMember Member member) {
        InviteLinkResponseDto response = chatRoomService.getInviteLink(chatRoomId, member);
        return ResponseEntity.ok(response);
    }

    // 초대 링크 정보 조회
    //alreadyJoined == true -> 바로 메세지 api 호출
    @GetMapping("/invite/{inviteCode}")
    public ResponseEntity<InviteCheckResponseDto> checkInvite(
            @PathVariable String inviteCode,
            @CurrentMember Member member) {
        InviteCheckResponseDto response = chatRoomService.checkInviteAccess(inviteCode, member);
        return ResponseEntity.ok(response);
    }

    // 초대 링크 검증 및 입장 처리
    @PostMapping("invite/{inviteCode}")
    public ResponseEntity<Long> enterChatRoomViaInvite(
            @PathVariable String inviteCode,
            @RequestParam(required = false) String password,
            @CurrentMember Member member) {

        Long chatRoomId = chatRoomService.enterChatRoomViaInvite(inviteCode, member, password);
        return ResponseEntity.ok(chatRoomId);
    }

    @GetMapping("/unread-count")
    public ResponseEntity<?> getTotalUnreadCount(@CurrentMember Member member) {
        int count = chatRoomService.getTotalUnreadCount(member);
        return ResponseEntity.ok(count);
    }
}
