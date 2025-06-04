package com.buddy.pium.controller.calender;

import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
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
    public ResponseEntity<List<CalendarResponseDto>> getAll(@CurrentMemberId Long memberId) {
        return ResponseEntity.ok(calenderService.getCalendersWithMate(memberId));
    }

    /**
     * 캘린더 생성
     */
    @PostMapping
    public ResponseEntity<CalendarResponseDto> create(@RequestBody CalendarRequestDto dto,
                                                      @CurrentMemberId Long memberId) {
        return ResponseEntity.ok(calenderService.createCalendar(memberId, dto));
    }

    /**
     * 캘린더 수정
     */
    @PatchMapping("/{id}")
    public ResponseEntity<CalendarResponseDto> update(@PathVariable Long id,
                                                      @RequestBody CalendarRequestDto dto,
                                                      @CurrentMemberId Long memberId) {
        return ResponseEntity.ok(calenderService.updateCalendar(id, dto, memberId));
    }

    /**
     * 캘린더 삭제
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id,
                                       @CurrentMemberId Long memberId) {
        calenderService.deleteCalendar(id, memberId);
        return ResponseEntity.noContent().build();
    }
}
