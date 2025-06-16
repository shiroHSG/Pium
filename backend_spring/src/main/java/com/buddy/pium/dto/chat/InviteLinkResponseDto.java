package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class InviteLinkResponseDto {
    private String inviteCode;
    private String inviteLink;
}
