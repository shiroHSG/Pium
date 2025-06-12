package com.buddy.pium.dto.share;

import com.buddy.pium.entity.share.Share;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ShareResponse {
    private Long id;
    private String title;
    private String content;
    private String postImg;
    private String author;
    private Long viewCount;
    private LocalDateTime createdAt;

    public static ShareResponse from(Share share) {
        return new ShareResponse(
                share.getId(),
                share.getTitle(),
                share.getContent(),
                share.getPostImg(),
                share.getMember().getNickname(),
                share.getViewCount(),
                share.getCreatedAt()
        );
    }
}
