package com.buddy.pium.dto.diary;

import com.buddy.pium.entity.diary.Diary;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiaryResponseDto {
    private Long id;
    private String title;
    private String content;
    private String publicContent;
    private boolean published;
    private String imageUrl;
    private String childName;
    private String author;
    private LocalDateTime createdAt;

    public static DiaryResponseDto from(Diary diary) {
        return DiaryResponseDto.builder()
                .id(diary.getId())
                .title(diary.getTitle())
                .content(diary.getContent())
                .publicContent(diary.getPublicContent())
                .published(diary.isPublished())
                .imageUrl(diary.getImageUrl())
                .childName(diary.getChild().getName())
                .author(diary.getMember().getNickname())
                .createdAt(diary.getCreatedAt())
                .build();
    }
}
