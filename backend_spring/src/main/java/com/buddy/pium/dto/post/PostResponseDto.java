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
    private String imageUrl;
    private String author;
    private Long viewCount;
    private LocalDateTime createdAt;
    private Integer likeCount;
    private Integer commentCount;
    private Boolean isLiked;

    public static PostResponseDto from(Post post, Long currentUserId) {
        boolean liked = post.getLikes().stream()
                .anyMatch(like -> like.getMember().getId().equals(currentUserId));
        return PostResponseDto.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .category(post.getCategory())
                .imageUrl(post.getImageUrl())
                .author(post.getMember().getNickname())
                .viewCount(post.getViewCount() == null ? 0 : post.getViewCount())
                .createdAt(post.getCreatedAt())
                .likeCount(post.getLikes().size())
                .commentCount(post.getPostComments().size())
                .isLiked(liked)
                .build();
    }
}