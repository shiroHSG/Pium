package com.buddy.pium.service.calender;

import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
import com.buddy.pium.entity.calender.Calender;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.calender.CalenderRepository;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CalenderService {

    private final CalenderRepository calenderRepository;
    private final MemberRepository memberRepository;

    public List<CalendarResponseDto> getCalendersWithMate(Long memberId) {
        Member member = memberRepository.findById(memberId).orElseThrow();
        Long mateId = member.getMateInfo();

        List<Calender> result = calenderRepository.findByMemberId(memberId);
        if (mateId != null) {
            result.addAll(calenderRepository.findByMemberId(mateId));
        }

        return result.stream().map(this::toDto).collect(Collectors.toList());
    }

    public CalendarResponseDto createCalendar(Long memberId, CalendarRequestDto dto) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        Calender calender = Calender.builder()
                .member(member)
                .title(dto.getTitle())
                .content(dto.getContent())
                .start_time(dto.getStart_time())
                .end_time(dto.getEnd_time())
                .color_tag(dto.getColor_tag())
                .createdAt(LocalDateTime.now())  // ✅ 수정
                .updatedAt(LocalDateTime.now())  // ✅ 수정
                .build();

        return toDto(calenderRepository.save(calender));
    }

    @Transactional
    public CalendarResponseDto updateCalendar(Long calendarId, CalendarRequestDto dto, Long memberId) {
        Calender calender = calenderRepository.findById(calendarId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 캘린더입니다."));

        if (!calender.getMember().getId().equals(memberId)) {
            throw new AccessDeniedException("수정 권한이 없습니다.");
        }

        if (dto.getTitle() != null) calender.setTitle(dto.getTitle());
        if (dto.getContent() != null) calender.setContent(dto.getContent());
        if (dto.getStart_time() != null) calender.setStart_time(dto.getStart_time());
        if (dto.getEnd_time() != null) calender.setEnd_time(dto.getEnd_time());
        if (dto.getColor_tag() != null) calender.setColor_tag(dto.getColor_tag());

        calender.setUpdatedAt(LocalDateTime.now());  // ✅ 수정

        return toDto(calenderRepository.save(calender));
    }

    public void deleteCalendar(Long calendarId, Long memberId) {
        Calender calender = calenderRepository.findById(calendarId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 캘린더입니다."));

        if (!calender.getMember().getId().equals(memberId)) {
            throw new AccessDeniedException("삭제 권한이 없습니다.");
        }

        calenderRepository.deleteById(calendarId);
    }

    private CalendarResponseDto toDto(Calender cal) {
        CalendarResponseDto dto = new CalendarResponseDto();
        dto.setId(cal.getId());
        dto.setTitle(cal.getTitle());
        dto.setContent(cal.getContent());
        dto.setStart_time(cal.getStart_time());
        dto.setEnd_time(cal.getEnd_time());
        dto.setColor_tag(cal.getColor_tag());
        dto.setCreatedAt(cal.getCreatedAt());  // ✅ 수정: toLocalDateTime 제거
        dto.setUpdatedAt(cal.getUpdatedAt());  // ✅ 수정: toLocalDateTime 제거
        return dto;
    }
}
