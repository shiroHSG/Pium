package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class InviteCheckResponseDto {
    private String chatRoomName;
    private boolean alreadyJoined;
    private boolean requirePassword;
}