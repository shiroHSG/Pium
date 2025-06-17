package com.buddy.pium.dto.diary;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DiaryUpdateDto {
    private String title;
    private String content;
    private String publicContent;
    private boolean published;
    private String imageUrl;
}
