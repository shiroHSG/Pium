package com.buddy.pium.entity.chat;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EntityListeners(AuditingEntityListener.class)
public class ChatRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private boolean isGroup;

    @Column(name = "chatroom_name")
    private String chatRoomName;

    private String password;

    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "last_message", columnDefinition = "TEXT")
    private String lastMessageContent;

    @Column(name = "last_sent_at")
    private LocalDateTime lastMessageSentAt;

    @CreatedDate
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;
}
