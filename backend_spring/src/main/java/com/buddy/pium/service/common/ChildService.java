package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.ChildRequestDto;
import com.buddy.pium.dto.common.ChildResponseDto;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class ChildService {

    private final ChildRepository childRepository;
    private final MemberRepository memberRepository;

    public ChildResponseDto createChild(Long memberId, ChildRequestDto dto) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        Child child = Child.builder()
                .member(member)
                .name(dto.getName())
                .birth(dto.getBirth())
                .gender(dto.getGender())
                .height(dto.getHeight())
                .weight(dto.getWeight())
                .profileImg(dto.getProfileImg())
                .sensitiveInfo(dto.getSensitiveInfo())
                .build();

        return toResponseDto(childRepository.save(child));
    }

    public ChildResponseDto updateChild(Long memberId, Long childId, ChildRequestDto dto) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));

        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("Unauthorized update attempt");
        }

        child.setName(dto.getName());
        child.setBirth(dto.getBirth());
        child.setGender(dto.getGender());
        child.setHeight(dto.getHeight());
        child.setWeight(dto.getWeight());
        child.setProfileImg(dto.getProfileImg());
        child.setSensitiveInfo(dto.getSensitiveInfo());

        return toResponseDto(childRepository.save(child));
    }

    public void deleteChild(Long memberId, Long childId) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));

        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("Unauthorized delete attempt");
        }

        childRepository.delete(child);
    }

    public ChildResponseDto getChild(Long memberId, Long childId) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));

        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("Unauthorized access");
        }

        return toResponseDto(child);
    }

    public List<ChildResponseDto> getAllChildren(Long memberId) {
        return childRepository.findAllByMemberId(memberId).stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    private ChildResponseDto toResponseDto(Child child) {
        return ChildResponseDto.builder()
                .id(child.getId())
                .name(child.getName())
                .birth(child.getBirth())
                .gender(child.getGender())
                .height(child.getHeight())
                .weight(child.getWeight())
                .profileImg(child.getProfileImg())
                .sensitiveInfo(child.getSensitiveInfo())
                .build();
    }
}
