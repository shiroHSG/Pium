package com.buddy.pium.entity.chat;

import com.buddy.pium.entity.post.SharePost;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    // DIRECT, SHARE, GROUP
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 10)
    private Enum.ChatRoomType type;

    // SHARE일때만 사용, 나머지 null
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "share_post_id")
    private SharePost sharePost;

    // GROUP일 때만 사용
    @Column(name = "chatroom_name")
    private String chatRoomName;
    private String password;
    @Column(name = "image_url")
    private String imageUrl;

    @Column(name = "last_message", columnDefinition = "TEXT")
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
}
