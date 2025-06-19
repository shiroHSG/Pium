package com.buddy.pium.dto.post;

import com.buddy.pium.entity.post.Post;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostResponse {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String imgUrl;
    private String author;
    private Long viewCount;
    private LocalDateTime createdAt;
    private Integer likeCount;
    private Boolean isLiked;
    private Integer commentCount;

    public static PostResponse from(Post post, Long currentUserId) {
        boolean liked = false;
        if (currentUserId != null) {
            liked = post.getLikes().stream()
                    .anyMatch(like -> like.getMember().getId().equals(currentUserId));
        }
        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getContent(),
                post.getCategory(),
                post.getImgUrl(),
                post.getMember().getNickname(),
                post.getViewCount() != null ? post.getViewCount() : 0,
                post.getCreatedAt(),
                post.getLikes() != null ? post.getLikes().size() : 0,
                liked,
                post.getPostComments() != null ? post.getPostComments().size() : 0
        );
    }

}
