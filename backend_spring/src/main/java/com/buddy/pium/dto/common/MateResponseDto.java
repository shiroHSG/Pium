package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
public class MateResponseDto {
    private Long requestId;
    private Long senderId;
    private String senderUsername;
    private String senderNickname;
    private Long receiverId;
    private String receiverUsername;
    private String receiverNickname;
    private MateRequestStatus status;
    private String message;
    private LocalDateTime updatedAt;
}