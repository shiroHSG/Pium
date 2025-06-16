package com.buddy.pium.dto.post;

import com.buddy.pium.entity.post.Post;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostResponseDto {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String imgUrl;
    private String author;
    private Long viewCount;
    private LocalDateTime createdAt;

    public static PostResponseDto from(Post post) {
        return new PostResponseDto(
                post.getId(),
                post.getTitle(),
                post.getContent(),
                post.getCategory(),
                post.getImageUrl(),
                post.getMember().getNickname(),
                post.getViewCount() != null ? post.getViewCount() : 0,
                post.getCreatedAt()
        );
    }
}
