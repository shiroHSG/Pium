package com.buddy.pium.dto.post;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class PostUpdateRequest {
    private String title;
    private String content;
    private String postImg;
}
// 글 수정