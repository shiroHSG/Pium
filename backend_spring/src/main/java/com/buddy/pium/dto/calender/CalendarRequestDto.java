package com.buddy.pium.dto.calender;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CalendarRequestDto {
    private String title;
    private String content;
    private LocalDateTime start_time;
    private LocalDateTime end_time;
    private String color_tag;
}
