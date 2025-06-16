package com.buddy.pium.dto.diary;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DiaryRequestDto {
    private Long childId;
    private String content;
    private String imageUrl;
}
