package com.buddy.pium.dto.chat;

import lombok.Data;

@Data
public class MessageRequestDTO {
    private Long senderId;  //테스트용
    private String content;
}
