package com.buddy.pium.dto.chat;

import com.buddy.pium.entity.chat.Enum;
import lombok.*;
import org.antlr.v4.runtime.misc.NotNull;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChatRoomRequestDto {

    @NotNull
    private Enum.ChatRoomType type; //DIRECT, SHARE, GROUP

    // ✅ direct / share
    private Long receiverId;

    // ✅ share only
    private Long shareId;

    // ✅ group only
    private String chatRoomName;
    private String password;
//    private String imageUrl;
}