package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum.Gender;
import lombok.*;

        import java.sql.Timestamp;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ChildDto {
    private Long childId;
    private String name;
    private LocalDate birth;
    private Gender gender;
    private Double height;
    private Double weight;
    private String profileImg;
    private String sensitiveInfo;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}