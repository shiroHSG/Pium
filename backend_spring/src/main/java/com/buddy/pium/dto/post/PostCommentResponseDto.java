package com.buddy.pium.dto.post;

import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
public class PostCommentResponseDto {
    private Long id;
    private String content;
    private String writer;
    private String createdAt;
}
// 댓글 조회