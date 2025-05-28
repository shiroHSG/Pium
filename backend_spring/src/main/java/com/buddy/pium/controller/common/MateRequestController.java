package com.buddy.pium.controller.common;

import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.service.common.MateRequestService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/mate-request")
@RequiredArgsConstructor
public class MateRequestController {

    private final MateRequestService mateRequestService;

    @PostMapping
    public ResponseEntity<MateRequest> sendMateRequest(@RequestParam Long senderId, @RequestParam Long receiverId) {
        return ResponseEntity.ok(mateRequestService.sendRequest(senderId, receiverId));
    }

    @GetMapping("/received")
    public ResponseEntity<List<MateRequest>> getReceived(@RequestParam Long memberId) {
        return ResponseEntity.ok(mateRequestService.getReceivedRequests(memberId));
    }

    @PutMapping("/{requestId}/accept")
    public ResponseEntity<Void> accept(@PathVariable Long requestId) {
        mateRequestService.acceptRequest(requestId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{requestId}/reject")
    public ResponseEntity<Void> reject(@PathVariable Long requestId) {
        mateRequestService.rejectRequest(requestId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/sent")
    public ResponseEntity<List<MateRequest>> getSent(@RequestParam Long memberId) {
        return ResponseEntity.ok(mateRequestService.getSentRequests(memberId));
    }

}
