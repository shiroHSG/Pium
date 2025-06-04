package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Child;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildResponseDto {
    private Long id;
    private String name;
    private LocalDate birth;
    private String gender;
    private Double height;
    private Double weight;
    private String profileImg;
    private String sensitiveInfo;
    private LocalDateTime createdAt;  // ✅ 추가
    private LocalDateTime updatedAt;  // ✅ 추가

    public static ChildResponseDto from(Child child) {
        return ChildResponseDto.builder()
                .id(child.getId())
                .name(child.getName())
                .birth(child.getBirth())
                .gender(child.getGender().name())
                .height(child.getHeight())
                .weight(child.getWeight())
                .profileImg(child.getProfileImg())
                .sensitiveInfo(child.getSensitiveInfo())
                .createdAt(child.getCreatedAt())  // ✅ 추가
                .updatedAt(child.getUpdatedAt())  // ✅ 추가
                .build();
    }
}
