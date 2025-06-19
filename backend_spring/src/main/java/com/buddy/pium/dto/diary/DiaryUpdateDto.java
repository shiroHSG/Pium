package com.buddy.pium.dto.diary;

import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Getter
@Setter
public class DiaryUpdateDto {
    private String title;
    private String content;
    private String publicContent;
    private Boolean published;
    private String imageUrl;

    private List<MultipartFile> imageFiles; // ✅ 추가
    private Boolean removeImage; // ✅ 이 줄 추가
}
