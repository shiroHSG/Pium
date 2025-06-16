package com.buddy.pium.dto.calender;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class CalendarRequestDto {
    private String title;
    private String content;
    private LocalDateTime startTime;
    private String colorTag;
}
