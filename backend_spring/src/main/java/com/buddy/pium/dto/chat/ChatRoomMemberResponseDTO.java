package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomMemberResponseDTO {
    private Long memberId;
    private String nickname;
    private String profileImageUrl;
    private boolean isAdmin;
}
