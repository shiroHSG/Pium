package com.buddy.pium.service.calender;

import com.buddy.pium.dto.calender.CalendarRequestDto;
import com.buddy.pium.dto.calender.CalendarResponseDto;
import com.buddy.pium.entity.calender.Calender;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.calender.CalenderRepository;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
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
        Member member = memberRepository.findById(memberId).orElseThrow();

        Calender calender = Calender.builder()
                .member(member)
                .title(dto.getTitle())
                .content(dto.getContent())
                .start_time(dto.getStart_time())
                .end_time(dto.getEnd_time())
                .color_tag(dto.getColor_tag())
                .createdAt(new Timestamp(System.currentTimeMillis()))
                .updatedAt(new Timestamp(System.currentTimeMillis()))
                .build();

        return toDto(calenderRepository.save(calender));
    }

    @Transactional
    public CalendarResponseDto updateCalendar(Long id, CalendarRequestDto dto) {
        Calender calender = calenderRepository.findById(id).orElseThrow();

        if (dto.getTitle() != null) {
            calender.setTitle(dto.getTitle());
        }
        if (dto.getContent() != null) {
            calender.setContent(dto.getContent());
        }
        if (dto.getStart_time() != null) {
            calender.setStart_time(dto.getStart_time());
        }
        if (dto.getEnd_time() != null) {
            calender.setEnd_time(dto.getEnd_time());
        }
        if (dto.getColor_tag() != null) {
            calender.setColor_tag(dto.getColor_tag());
        }

        // ✅ 명시적으로 save 호출하여 DB 반영 보장
        Calender updated = calenderRepository.save(calender);
        return toDto(updated);
    }

    public void deleteCalendar(Long id) {
        calenderRepository.deleteById(id);
    }

    private CalendarResponseDto toDto(Calender cal) {
        CalendarResponseDto dto = new CalendarResponseDto();
        dto.setId(cal.getId());
        dto.setTitle(cal.getTitle());
        dto.setContent(cal.getContent());
        dto.setStart_time(cal.getStart_time());
        dto.setEnd_time(cal.getEnd_time());
        dto.setColor_tag(cal.getColor_tag());
        dto.setCreatedAt(cal.getCreatedAt().toLocalDateTime());
        dto.setUpdatedAt(cal.getUpdatedAt().toLocalDateTime());
        return dto;
    }
}
