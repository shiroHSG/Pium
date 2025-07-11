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

    // ✅ 주소 필드 추가
    private String addressCity;
    private String addressDistrict;
    private String addressDong;

    public static PostResponseDto from(Post post, Long currentUserId) {
        boolean liked = post.getLikes().stream()
                .anyMatch(like -> like.getMember().getId().equals(currentUserId));

        // Member에서 주소 파싱
        String address = post.getMember().getAddress();
        String[] tokens = address != null ? address.split(" ") : new String[0];
        String city = tokens.length > 0 ? tokens[0] : "";
        String district = tokens.length > 1 ? tokens[1] : "";
        String dong = tokens.length > 2 ? tokens[2] : "";

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
                // ✅ 주소 파싱 값 세팅
                .addressCity(city)
                .addressDistrict(district)
                .addressDong(dong)
                .build();
    }
}
