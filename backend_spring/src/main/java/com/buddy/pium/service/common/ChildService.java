package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChildService {

    private final ChildRepository childRepository;
    private final MemberRepository memberRepository;

    public void addChild(ChildRegisterDto dto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("Member not found"));

        Child child = Child.builder()
                .member(member)
                .name(dto.getName())
                .birth(dto.getBirth())
                .gender(dto.getGender())
                .height(dto.getHeight())
                .weight(dto.getWeight())
                .profileImgUrl(dto.getProfileImgUrl())
                .sensitiveInfo(dto.getSensitiveInfo())
                .build();

        childRepository.save(child);
    }

    public void deleteChild(Long childId, Long memberId) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));
        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한이 없습니다.");
        }
        childRepository.delete(child);
    }

    @Transactional
    public void updateChild(Long childId, ChildUpdateDto dto, Long memberId) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));

        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한이 없습니다.");
        }

        if (dto.getName() != null) child.setName(dto.getName());
        if (dto.getBirth() != null) child.setBirth(dto.getBirth());
        if (dto.getGender() != null) child.setGender(dto.getGender());
        if (dto.getHeight() != null) child.setHeight(dto.getHeight());
        if (dto.getWeight() != null) child.setWeight(dto.getWeight());
        if (dto.getProfileImgUrl() != null) child.setProfileImgUrl(dto.getProfileImgUrl());
        if (dto.getSensitiveInfo() != null) child.setSensitiveInfo(dto.getSensitiveInfo());
    }

    public List<ChildResponseDto> getChildren(Long memberId, Long mateId) {
        if (mateId != null) {
            return childRepository.findByMemberIdIn(List.of(memberId, mateId))
                    .stream()
                    .map(ChildResponseDto::from)
                    .collect(Collectors.toList());
        } else {
            return childRepository.findByMemberId(memberId)
                    .stream()
                    .map(ChildResponseDto::from)
                    .collect(Collectors.toList());
        }
    }
    public ChildResponseDto getChildById(Long childId, Long memberId) {
        Child child = childRepository.findByIdAndMemberId(childId, memberId)
                .orElseThrow(() -> new RuntimeException("아이를 찾을 수 없거나 권한이 없습니다."));

        return ChildResponseDto.from(child); // 정적 팩토리 메서드로 변환
    }
}