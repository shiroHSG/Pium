package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class ChatRoomSummaryDto {
    private Long roomId;
    private String lastMessage;
    private int unreadCount;
    private LocalDateTime lastSentAt;
}
