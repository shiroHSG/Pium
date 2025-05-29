package com.buddy.pium.dto.chat;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomRequestDTO {

    // ✅ true: 단체 채팅방, false: 1:1(DM/나눔)
    private Boolean isGroup;

    // ✅ group only
    private String chatRoomName;
    private String password;
    private String imageUrl;

    // ✅ direct / share
    private Long receiverId;

    // ✅ share only
    private Long postId;
}