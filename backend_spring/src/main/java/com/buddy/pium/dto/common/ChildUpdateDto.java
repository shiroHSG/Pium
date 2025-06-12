package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildUpdateDto {
    private String name;
    private LocalDate birth;
    private Enum.Gender gender;
    private Double height;
    private Double weight;
    private String profileImgUrl;
    private String sensitiveInfo;
}
