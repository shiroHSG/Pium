package com.buddy.pium.dto.post;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PostListItemDto {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private String nickname; // 작성자 닉네임

    // 엔티티 → Dto 변환 편의 메서드
    public static PostListItemDto fromEntity(com.buddy.pium.entity.post.Post post) {
        return PostListItemDto.builder()
                .id(post.getId())
                .title(post.getTitle())
                .content(post.getContent())
                .createdAt(post.getCreatedAt())
                .nickname(post.getMember().getNickname())
                .build();
    }
}
