package com.buddy.pium.dto.post;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class PostUpdateDto {
    private String title;
    private String content;
    private String category;
}
// 글 수정