// PostResponse.java
package com.buddy.pium.dto.post;

import com.buddy.pium.entity.post.Post;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PostResponseDto {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String imgUrl;
    private String author;
    private Long viewCount;
    private String createdAt;
    private Integer likeCount;
    private Boolean isLiked;
    private Integer commentCount;

    public static PostResponseDto from(Post post, Long memberId) {
        return PostResponseDto.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .category(post.getCategory())
                .author(post.getMember().getNickname())
                .viewCount(post.getViewCount())
                .createdAt(post.getCreatedAt().toString())
                .likeCount(post.getLikes().size())
                .build();
    }
}
