// PostResponse.java
package com.buddy.pium.dto.post;

import com.buddy.pium.entity.post.Post;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PostResponse {
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

    public static PostResponse from(Post post, Long memberId) {
        return PostResponse.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .category(post.getCategory())
                .imgUrl(post.getImgUrl())
                .author(post.getMember().getNickname())
                .viewCount(post.getViewCount())
                .createdAt(post.getCreatedAt().toString())
                .likeCount(post.getLikes().size())
                .isLiked(post.isLikedBy(memberId))
                .commentCount(post.getComments().size())
                .build();
    }
}
