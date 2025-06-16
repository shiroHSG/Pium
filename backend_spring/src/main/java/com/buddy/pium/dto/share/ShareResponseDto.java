package com.buddy.pium.dto.share;

import com.buddy.pium.entity.share.Share;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ShareResponseDto {
    private Long id;
    private String title;
    private String content;
    private String imgUrl;
    private String author;
    private Long viewCount;
    private LocalDateTime createdAt;

    public static ShareResponseDto from(Share share) {
        return new ShareResponseDto(
                share.getId(),
                share.getTitle(),
                share.getContent(),
                share.getImageUrl(),
                share.getMember().getNickname(),
                share.getViewCount(),
                share.getCreatedAt()
        );
    }
}
