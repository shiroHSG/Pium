package com.buddy.pium.dto.diary;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class DiaryUpdateRequest {
    private String content;
    private String imageUrl;
}
