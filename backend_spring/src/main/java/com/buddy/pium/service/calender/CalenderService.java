package com.buddy.pium.service.calender;

import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
import com.buddy.pium.entity.calender.Calender;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.calender.CalenderRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.service.common.MemberService;
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
    private final MemberService memberService;

    public List<CalendarResponseDto> getCalendersWithMate(Member member) {
        Long mateId = member.getMateInfo();

        List<Calender> result = calenderRepository.findByMember(member);
        if (mateId != null) {
            result.addAll(calenderRepository.findByMemberId(mateId));
        }

        return result.stream().map(this::toDto).collect(Collectors.toList());
    }

    public CalendarResponseDto createCalendar(Member member, CalendarRequestDto dto) {
        Calender calender = Calender.builder()
                .member(member)
                .title(dto.getTitle())
                .content(dto.getContent())
                .startTime(dto.getStartTime())
                .colorTag(dto.getColorTag())
                .createdAt(LocalDateTime.now())  // ✅ 수정
                .updatedAt(LocalDateTime.now())  // ✅ 수정
                .build();

        return toDto(calenderRepository.save(calender));
    }

    @Transactional
    public CalendarResponseDto updateCalendar(Long calendarId, CalendarRequestDto dto, Member member) {
        Calender calender = validateCalender(calendarId);
        authCalenderMember(calender, member);

        if (dto.getTitle() != null) calender.setTitle(dto.getTitle());
        if (dto.getContent() != null) calender.setContent(dto.getContent());
        if (dto.getStartTime() != null) calender.setStartTime(dto.getStartTime());
        if (dto.getColorTag() != null) calender.setColorTag(dto.getColorTag());

        calender.setUpdatedAt(LocalDateTime.now());  // ✅ 수정

        return toDto(calenderRepository.save(calender));
    }

    public void deleteCalendar(Long calendarId, Member member) {
        Calender calender = validateCalender(calendarId);
        authCalenderMember(calender, member);

        calenderRepository.deleteById(calendarId);
    }

    private CalendarResponseDto toDto(Calender cal) {
        return CalendarResponseDto.builder()
                .id(cal.getId())
                .title(cal.getTitle())
                .content(cal.getContent())
                .startTime(cal.getStartTime())
                .colorTag(cal.getColorTag())
                .createdAt(cal.getCreatedAt())   // ✅ toLocalDateTime 제거된 그대로 유지
                .updatedAt(cal.getUpdatedAt())   // ✅ toLocalDateTime 제거된 그대로 유지
                .build();
    }

    public Calender validateCalender(Long calendarId) {
        return calenderRepository.findById(calendarId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 캘린더입니다."));
    }

    public void authCalenderMember(Calender calender, Member member) {
        Member owner = calender.getMember();
        if (!owner.equals(member) && !owner.equals(member.getMateInfo())) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
    }
}
