package com.buddy.pium.dto.calender;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CalendarResponseDto {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime startTime;
    private String colorTag;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
