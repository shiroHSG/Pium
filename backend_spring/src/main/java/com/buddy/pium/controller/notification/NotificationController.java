package com.buddy.pium.controller.notification;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.notification.NotificationResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.notification.NotificationRepository;
import com.buddy.pium.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/notifications")
public class NotificationController {

    private final NotificationService notificationService;

    // ✅ SSE 연결
    @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    public SseEmitter subscribe(@CurrentMember Member member) {
        return notificationService.subscribe(member.getId());
    }

    // ✅ 안 읽은 알림 조회
    @GetMapping("/unread")
    public ResponseEntity<List<NotificationResponseDto>> getUnreadNotifications(@CurrentMember Member member) {
        List<NotificationResponseDto> unreadList = notificationService.getUnreadMessages(member.getId());
        return ResponseEntity.ok(unreadList);
    }

    // ✅ 전체 읽음 처리
    @PostMapping("/mark-as-read")
    public ResponseEntity<?> markAsRead(@CurrentMember Member member) {
        notificationService.markAllAsRead(member.getId());
        return ResponseEntity.ok(Map.of("message", "읽음 처리 완료"));
    }

    // ✅ 안 읽은 알림 수 반환
    @GetMapping("/unread-count")
    public ResponseEntity<Integer> getUnreadCount(@CurrentMember Member member) {
        int count = notificationService.getUnreadNotificationCount(member.getId());
        return ResponseEntity.ok(count);
    }
}

