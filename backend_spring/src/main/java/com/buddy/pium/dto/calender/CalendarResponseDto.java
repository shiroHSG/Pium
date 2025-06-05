package com.buddy.pium.dto.calender;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CalendarResponseDto {
    private Long id;
    private String title;
    private String content;
    private LocalDateTime start_time;
    private LocalDateTime end_time;
    private String color_tag;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}
