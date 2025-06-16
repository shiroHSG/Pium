package com.buddy.pium.dto.chat;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatRoomSummaryDto {
    private Long chatRoomId;
    private String lastMessage;
    private int unreadCount;
    private LocalDateTime lastSentAt;
}
