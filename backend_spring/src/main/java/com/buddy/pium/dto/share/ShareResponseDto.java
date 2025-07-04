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
    private Long authorMemberId;     // Member ID
    private String category;
    private Long viewCount;
    private LocalDateTime createdAt;
    private int likeCount;

    // 아래 세 개가 추가된 필드입니다.
    private String addressCity;      // 시/도
    private String addressDistrict;  // 구/군
    private String addressDong;      // 동

    // DTO 생성 메서드 (address 파싱값 추가)
    public static ShareResponseDto from(Share share, int likeCount, String addressCity, String addressDistrict, String addressDong) {
        return new ShareResponseDto(
                share.getId(),
                share.getTitle(),
                share.getContent(),
                share.getImageUrl(),
                share.getMember().getNickname(),
                share.getMember().getId(),
                share.getCategory(),
                share.getViewCount(),
                share.getCreatedAt(),
                likeCount,
                addressCity,
                addressDistrict,
                addressDong
        );
    }
}
