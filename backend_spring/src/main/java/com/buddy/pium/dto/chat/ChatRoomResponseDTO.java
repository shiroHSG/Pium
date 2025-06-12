package com.buddy.pium.dto.chat;

import com.buddy.pium.entity.chat.Enum;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomResponseDTO {

    private Long chatRoomId;
    private Enum.ChatRoomType type;

    // DIRECT , SHARE
    private String otherNickname;
    private String otherProfileImageUrl;
    // SHARE
    private Long sharePostId;

    // GROUP
    private String chatRoomName;
    private String imageUrl;

    private String lastMessage;
    private LocalDateTime lastSentAt;

    private int unreadCount;
}
