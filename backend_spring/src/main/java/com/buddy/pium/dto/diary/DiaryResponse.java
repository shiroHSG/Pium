package com.buddy.pium.dto.diary;

import com.buddy.pium.entity.diary.Diary;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class DiaryResponse {
    private Long id;
    private String content;
    private String imageUrl;
    private String childName;
    private String author;
    private LocalDateTime createdAt;

    public static DiaryResponse from(Diary diary) {
        return DiaryResponse.builder()
                .id(diary.getId())
                .content(diary.getContent())
                .imageUrl(diary.getImageUrl())
                .childName(diary.getChild().getName())
                .author(diary.getMember().getNickname())
                .createdAt(diary.getCreatedAt())
                .build();
    }
}
