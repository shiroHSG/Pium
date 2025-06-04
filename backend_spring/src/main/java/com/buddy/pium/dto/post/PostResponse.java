package com.buddy.pium.dto.post;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class PostResponse {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String postImg;
    private Member author;
    private int viewCount;
    private LocalDateTime createdAt;

    public static PostResponse from(Post post) {
        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getContent(),
                post.getCategory(),
                post.getPostImg(),
                post.getMember(),
                post.getViewCount(),
                post.getCreatedAt()
        );
    }
}
// 글 조회