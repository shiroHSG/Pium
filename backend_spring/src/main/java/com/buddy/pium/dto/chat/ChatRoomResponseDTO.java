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

    private Long sharePostId;

    private String chatRoomName;
    private String imageUrl;
    private String lastMessage;
    private LocalDateTime lastSentAt;
}
