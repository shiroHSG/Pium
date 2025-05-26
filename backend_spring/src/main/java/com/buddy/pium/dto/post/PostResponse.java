package com.buddy.pium.dto.post;

import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter @AllArgsConstructor
public class PostResponse {
    private Long id;
    private String title;
    private String content;
    private String category;
    private String postImg;
    private String author;
    private int viewCount;
    private LocalDateTime createdAt;
}
