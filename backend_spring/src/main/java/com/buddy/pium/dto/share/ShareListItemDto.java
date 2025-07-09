package com.buddy.pium.dto.share;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ShareListItemDto {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime createdAt;
    private String nickname; // 작성자 닉네임

    public static ShareListItemDto fromEntity(com.buddy.pium.entity.share.Share share) {
        return ShareListItemDto.builder()
                .id(share.getId())
                .title(share.getTitle())
                .content(share.getContent())
                .createdAt(share.getCreatedAt())
                .nickname(share.getMember().getNickname())
                .build();
    }
}
