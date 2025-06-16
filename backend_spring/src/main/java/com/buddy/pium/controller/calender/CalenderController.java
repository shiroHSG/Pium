package com.buddy.pium.controller.calender;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.calender.CalenderService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/calendar")
public class CalenderController {

    private final CalenderService calenderService;

    /**
     * 캘린더 전체 조회 (본인 + mateInfo 포함)
     */
    @GetMapping
    public ResponseEntity<List<CalendarResponseDto>> getAll(@CurrentMember Member member) {
        return ResponseEntity.ok(calenderService.getCalendersWithMate(member));
    }

    /**
     * 캘린더 생성
     */
    @PostMapping
    public ResponseEntity<CalendarResponseDto> create(@RequestBody CalendarRequestDto dto,
                                                      @CurrentMember Member member) {
        return ResponseEntity.ok(calenderService.createCalendar(member, dto));
    }

    /**
     * 캘린더 수정
     */
    @PatchMapping("/{calendarId}")
    public ResponseEntity<CalendarResponseDto> update(@PathVariable Long calendarId,
                                                      @RequestBody CalendarRequestDto dto,
                                                      @CurrentMember Member member) {
        return ResponseEntity.ok(calenderService.updateCalendar(calendarId, dto, member));
    }

    /**
     * 캘린더 삭제
     */
    @DeleteMapping("/{calendarId}")
    public ResponseEntity<Void> delete(@PathVariable Long calendarId,
                                       @CurrentMember Member member) {
        calenderService.deleteCalendar(calendarId, member);
        return ResponseEntity.noContent().build();
    }
}
