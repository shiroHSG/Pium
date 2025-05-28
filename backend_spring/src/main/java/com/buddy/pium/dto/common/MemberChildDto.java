package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum.RelationType;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberChildDto {
    private Long id;
    private Long memberId;
    private Long childId;
    private RelationType relationType;
    private LocalDate registeredAt;
}
