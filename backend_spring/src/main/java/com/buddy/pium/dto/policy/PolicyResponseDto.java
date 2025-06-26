package com.buddy.pium.dto.policy;

import com.buddy.pium.entity.policy.Policy;
import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PolicyResponseDto {

    private Long id;
    private String title;
    private String content;
    private Long viewCount;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDateTime createdAt;

    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd")
    private LocalDateTime updatedAt;

    public static PolicyResponseDto fromEntity(Policy policy) {
        return PolicyResponseDto.builder()
                .id(policy.getId())
                .title(policy.getTitle())
                .content(policy.getContent())
                .viewCount(policy.getViewCount())
                .createdAt(policy.getCreatedAt())
                .updatedAt(policy.getUpdatedAt())
                .build();
    }
}
