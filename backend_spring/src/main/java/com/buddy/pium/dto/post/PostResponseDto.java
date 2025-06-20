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
    private Integer likeCount;
    private Boolean isLiked;
    private Integer commentCount;

<<<<<<< HEAD:backend_spring/src/main/java/com/buddy/pium/dto/post/PostResponse.java
    public static PostResponse from(Post post, Long currentUserId) {
        boolean liked = false;
        if (currentUserId != null) {
            liked = post.getLikes().stream()
                    .anyMatch(like -> like.getMember().getId().equals(currentUserId));
        }
        return new PostResponse(
=======
    public static PostResponseDto from(Post post) {
        return new PostResponseDto(
>>>>>>> 97b761ed9afd878756cbc460c640dc0dc6bf36f2:backend_spring/src/main/java/com/buddy/pium/dto/post/PostResponseDto.java
                post.getId(),
                post.getTitle(),
                post.getContent(),
                post.getCategory(),
                post.getImageUrl(),
                post.getMember().getNickname(),
                post.getViewCount() != null ? post.getViewCount() : 0,
                post.getCreatedAt(),
                post.getLikes() != null ? post.getLikes().size() : 0,
                liked,
                post.getPostComments() != null ? post.getPostComments().size() : 0
        );
    }

}
