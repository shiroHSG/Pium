package com.buddy.pium.dto.calender;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@Builder
public class CalendarResponseDto {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime startTime;
    private String colorTag;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
