package com.buddy.pium.dto.post;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class PostRequestDto {
    private String category;
    private String title;
    private String content;
}
// 글 작성