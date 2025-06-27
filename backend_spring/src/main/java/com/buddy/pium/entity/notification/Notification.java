package com.buddy.pium.entity.notification;

import com.buddy.pium.entity.common.Member;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 알림을 받을 대상
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "receiver_id", nullable = false)
    private Member receiver;

    // 화면에 보여질 메시지
    @Column(nullable = false)
    private String message;

    // 알림 유형 (예: COMMENT, MATE_REQUEST)
    @Column(nullable = false)
    private String type;

    // 이동 대상 타입 (예: POST, MEMBER 등)
    private String targetType;

    // 이동 대상 ID (예: postId, memberId 등)
    private Long targetId;

    // 읽음 여부
    private boolean isRead;

    // 생성 시각
    @CreatedDate
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;
}
