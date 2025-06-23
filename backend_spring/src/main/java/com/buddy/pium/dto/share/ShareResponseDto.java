package com.buddy.pium.dto.share;

import com.buddy.pium.entity.share.Share;
import lombok.AllArgsConstructor;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@AllArgsConstructor
public class ShareResponseDto {
    private Long id;
    private String title;
    private String content;
    private String imgUrl;
    private String author;           // 닉네임
    private Long authorMemberId;     // ✅ Member ID 추가
    private Long viewCount;
    private LocalDateTime createdAt;

    public static ShareResponseDto from(Share share) {
        return new ShareResponseDto(
                share.getId(),
                share.getTitle(),
                share.getContent(),
                share.getImageUrl(),
                share.getMember().getNickname(),
                share.getMember().getId(),      // ✅ Member ID 설정
                share.getViewCount(),
                share.getCreatedAt()
        );
    }
}
