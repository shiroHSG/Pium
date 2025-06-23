package com.buddy.pium.dto.post;

import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
public class PostUpdateDto {
    private String title;
    private String content;
    private String category;
    private String imgUrl;
}
