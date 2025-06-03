package com.buddy.pium.controller.calender;

import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
import com.buddy.pium.service.calender.CalenderService;
import com.buddy.pium.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/calendar")
public class CalenderController {

    private final CalenderService calenderService;
    private final JwtUtil jwtUtil;

    @GetMapping
    public ResponseEntity<List<CalendarResponseDto>> getAll(Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(calenderService.getCalendersWithMate(memberId));
    }

    @PostMapping
    public ResponseEntity<CalendarResponseDto> create(@RequestBody CalendarRequestDto dto, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        return ResponseEntity.ok(calenderService.createCalendar(memberId, dto));
    }

    @PatchMapping("/{id}")
    public ResponseEntity<CalendarResponseDto> update(@PathVariable Long id, @RequestBody CalendarRequestDto dto) {
        return ResponseEntity.ok(calenderService.updateCalendar(id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        calenderService.deleteCalendar(id);
        return ResponseEntity.noContent().build();
    }
}
