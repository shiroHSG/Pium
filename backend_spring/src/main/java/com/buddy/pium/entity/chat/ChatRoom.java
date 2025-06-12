package com.buddy.pium.entity.chat;

import com.buddy.pium.entity.share.Share;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
@Table(name = "chatroom")
public class ChatRoom {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // DIRECT, SHARE, GROUP
    @Enumerated(EnumType.STRING)
    @Column(name = "chatroom_type", nullable = false, length = 10)
    private Enum.ChatRoomType type;

    // SHARE일때만 사용, 나머지 null
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "share_id")
    private Share share;

    // GROUP일 때만 사용
    @Column(name = "chatroom_name")
    private String chatRoomName;
    private String password;
    private String imageUrl;
    @Column(unique = true, length = 12)
    private String inviteCode;

    @Lob
    @Column(name = "last_message")
    private String lastMessageContent;

    @Column(name = "last_sent_at")
    private LocalDateTime lastMessageSentAt;

    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChatRoomMember> chatRoomMembers = new ArrayList<>();

    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<ChatRoomBan> chatRoomBan = new ArrayList<>();

    @OneToMany(mappedBy = "chatRoom", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Message> messages = new ArrayList<>();

    @CreatedDate
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}
