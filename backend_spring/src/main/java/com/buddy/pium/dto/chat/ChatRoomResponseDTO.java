package com.buddy.pium.dto.chat;

import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomResponseDTO {

    private Long chatRoomId;

    private boolean isGroup;

    private String chatRoomName;

    private String lastMessage;

    private LocalDateTime lastSentAt;
}
