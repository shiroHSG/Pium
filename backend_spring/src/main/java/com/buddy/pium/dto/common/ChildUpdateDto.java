package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@JsonIgnoreProperties(ignoreUnknown = true) // ✅ 알 수 없는 필드 무시
public class ChildUpdateDto {
    private String name;
    private LocalDate birth;
    private Enum.Gender gender;
    private Double height;
    private Double weight;
    private String sensitiveInfo;
    private String profileImgUrl;
}
