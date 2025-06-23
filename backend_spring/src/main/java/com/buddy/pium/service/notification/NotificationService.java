package com.buddy.pium.service.notification;

import com.buddy.pium.dto.notification.NotificationResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.notification.Notification;
import com.buddy.pium.repository.notification.NotificationRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.List;
import java.util.Map;
import java.util.concurrent.*;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final Map<Long, SseEmitter> emitters = new ConcurrentHashMap<>();
    private final Map<Long, ScheduledFuture<?>> heartbeatFutures = new ConcurrentHashMap<>();
    private final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(1);
    private final NotificationRepository notificationRepository;


    public SseEmitter subscribe(Long memberId) {
        System.out.println("✅ SSE 구독 시작: memberId = " + memberId);

        SseEmitter emitter = new SseEmitter(60 * 60 * 1000L); // 1시간 유지

        removeEmitter(memberId); // 중복 제거
        emitters.put(memberId, emitter);

        emitter.onCompletion(() -> removeEmitter(memberId));
        emitter.onTimeout(() -> removeEmitter(memberId));
        emitter.onError(e -> removeEmitter(memberId));

        try {
            // ✅ 최초 연결 직후 더미 데이터라도 하나 보내야 끊어지지 않음
            emitter.send(SseEmitter.event().name("connect").data("Connected"));
        } catch (IOException e) {
            throw new RuntimeException("SSE 연결 오류", e);
        }

        ScheduledFuture<?> future = startHeartbeat(memberId);
        return emitter;
    }

    private ScheduledFuture<?> startHeartbeat(Long memberId) {
        return scheduler.scheduleAtFixedRate(() -> {
            if (emitters.containsKey(memberId)) {
                try {
                    emitters.get(memberId).send(SseEmitter.event().name("heartbeat").data("heartbeat"));
                } catch (IOException e) {
                    System.out.println("Heartbeat 실패, emitter 제거: memberId = " + memberId);
                    removeEmitter(memberId);
                }
            }
        }, 0, 30, TimeUnit.SECONDS);
    }


    public List<NotificationResponseDto> getUnreadMessages(Long memberId) {
        return notificationRepository
                .findByReceiverIdAndIsReadFalseOrderByCreatedAtDesc(memberId)
                .stream()
                .map(NotificationResponseDto::from)
                .collect(Collectors.toList());
    }

    @Transactional
    public void markAllAsRead(Long memberId) {
        List<Notification> unreadList = notificationRepository
                .findByReceiverIdAndIsReadFalseOrderByCreatedAtDesc(memberId);

        for (Notification noti : unreadList) {
            noti.setRead(true);
        }

        notificationRepository.saveAll(unreadList);
    }

    private void removeEmitter(Long memberId) {
        SseEmitter emitter = emitters.remove(memberId);
        if (emitter != null) emitter.complete();

        ScheduledFuture<?> future = heartbeatFutures.remove(memberId);
        if (future != null) future.cancel(true);

        System.out.println("🧹 SSE 연결 정리 완료: memberId = " + memberId);
    }

    // 알림 보내기
    public void sendNotification(Long receiverId, String message, String type, String targetType, Long targetId) {
        // DB 저장
        Notification notification = Notification.builder()
                .receiver(Member.builder().id(receiverId).build()) // 더미 Member (연관 관계 저장용)
                .message(message)
                .type(type)
                .targetType(targetType)
                .targetId(targetId)
                .isRead(false)
                .build();

        notificationRepository.save(notification);
        System.out.println("알림 전송 컨트롤러 : " + notification);
        // 실시간 전송
        SseEmitter emitter = emitters.get(receiverId);
        System.out.println("알림 전송 receiverId : " + receiverId);
        System.out.println("알림 전송 emitter : " + emitter);

        if (emitter != null) {
            try {
                // 알림 내용 전송
                NotificationResponseDto dto = NotificationResponseDto.from(notification);
                emitter.send(SseEmitter.event()
                        .name("notification")
                        .data(dto));
                System.out.println("알림 전송 : " + dto);

                // unreadCount 전송
                int unreadCount = notificationRepository.countByReceiverIdAndIsReadFalse(receiverId);
                emitter.send(SseEmitter.event()
                        .name("unreadCount")   // ✅ 이벤트 이름: unreadCount
                        .data(unreadCount));
                System.out.println("📡 unreadCount 전송: " + unreadCount);
            } catch (IOException e) {
                System.out.println("💥 알림 전송 실패, emitter 제거: memberId = " + receiverId);
                removeEmitter(receiverId);
            }
        }
    }

    // 🔹 안 읽은 알림 개수 조회
    public int getUnreadNotificationCount(Long memberId) {
        return notificationRepository.countByReceiverIdAndIsReadFalse(memberId);
    }
}
