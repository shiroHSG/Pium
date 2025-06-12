package com.buddy.pium.entity.chat;

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
@Table(name = "chatroom_ban",
        uniqueConstraints = {@UniqueConstraint(columnNames = {"chatroom_id", "member_id"})})
public class ChatRoomBan {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="chatroom_id", nullable = false)
    private ChatRoom chatRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name="member_id", nullable = false)
    private Member bannedMember;

    @CreatedDate
    @Column(name = "banned_at", nullable = false)
    private LocalDateTime bannedAt;
}
