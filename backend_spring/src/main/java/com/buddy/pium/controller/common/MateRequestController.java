package com.buddy.pium.controller.common;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.dto.common.MateResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.MateRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/mate")
@RequiredArgsConstructor
public class MateRequestController {

    private final MateRequestService mateRequestService;

    // Mate 요청 전송
    @PostMapping("/request/{receiverId}")
    public ResponseEntity<Map<String, String>> requestMate(@PathVariable Long receiverId,
                                                           @CurrentMember Member member) {
        mateRequestService.requestMate(member, receiverId);
        return messageResponse("Mate 요청이 전송되었습니다.");
    }

    // Mate 요청 수락
    @PostMapping("/accept/{senderId}")
    public ResponseEntity<Map<String, String>> acceptMateBySender(@PathVariable Long senderId,
                                                                  @CurrentMember Member member) {
        mateRequestService.acceptMateBySender(senderId, member);
        return messageResponse("Mate 요청을 수락했습니다. 상대방과 연결되었습니다.");
    }

    // Mate 요청 거절
    @PostMapping("/reject/{senderId}")
    public ResponseEntity<Map<String, String>> rejectMateBySender(@PathVariable Long senderId,
                                                                  @CurrentMember Member member) {
        mateRequestService.rejectMateBySender(senderId, member);
        return messageResponse("Mate 요청을 거절했습니다.");
    }

    // Mate 연결 해제
    @PostMapping("/disconnect")
    public ResponseEntity<Map<String, String>> disconnectMate(@CurrentMember Member member) {
        mateRequestService.disconnectMate(member);
        return messageResponse("Mate 연결이 해제되었습니다.");
    }

    // 받은 Mate 요청 목록 조회
    @GetMapping("/received")
    public ResponseEntity<List<MateResponseDto>> getReceivedRequests(@CurrentMember Member member) {
        return ResponseEntity.ok(mateRequestService.getPendingRequests(member));
    }

    // 보낸 Mate 요청 목록 조회
    @GetMapping("/sent")
    public ResponseEntity<List<MateResponseDto>> getSentRequests(@CurrentMember Member member) {
        return ResponseEntity.ok(mateRequestService.getSentRequests(member));
    }

    // Mate 요청 취소
    @DeleteMapping("/cancel/{receiverId}")
    public ResponseEntity<Map<String, String>> cancelRequest(@PathVariable Long receiverId,
                                                             @CurrentMember Member member) {
        mateRequestService.cancelRequest(member, receiverId);
        return messageResponse("Mate 요청이 취소되었습니다.");
    }

    // ✅ 공통 메시지 응답 생성 메서드
    private ResponseEntity<Map<String, String>> messageResponse(String message) {
        Map<String, String> map = new HashMap<>();
        map.put("message", message);
        return ResponseEntity.ok(map);
    }
}
