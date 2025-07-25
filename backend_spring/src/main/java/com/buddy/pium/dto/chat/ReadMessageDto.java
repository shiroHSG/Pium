package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class ReadMessageDto {
    private Long readerId;
    private Long lastReadMessageId;
}
