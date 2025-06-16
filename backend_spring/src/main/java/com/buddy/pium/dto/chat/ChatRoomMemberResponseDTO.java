package com.buddy.pium.dto.chat;

import com.buddy.pium.entity.chat.ChatRoomMember;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomMemberResponseDTO {
    private Long memberId;
    private String nickname;
    private String profileImageUrl;
    private boolean isAdmin;

    public static ChatRoomMemberResponseDTO from(ChatRoomMember chatRoomMember) {
        return ChatRoomMemberResponseDTO.builder()
                .memberId(chatRoomMember.getMember().getId())
                .nickname(chatRoomMember.getMember().getNickname())
                .profileImageUrl(chatRoomMember.getMember().getProfileImageUrl())
                .isAdmin(chatRoomMember.isAdmin())
                .build();
    }
}
