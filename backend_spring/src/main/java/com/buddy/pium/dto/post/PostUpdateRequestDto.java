package com.buddy.pium.dto.post;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class PostUpdateRequestDto {
    private String title;
    private String content;
    private String imgUrl;
}
// 글 수정