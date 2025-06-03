package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

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
                .profileImg(dto.getProfileImg())
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

    public void updateChild(Long childId, ChildUpdateDto dto, Long memberId) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new RuntimeException("Child not found"));
        if (!child.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한이 없습니다.");
        }
        child.setName(dto.getName());
        child.setBirth(dto.getBirth());
        child.setGender(dto.getGender());
        child.setHeight(dto.getHeight());
        child.setWeight(dto.getWeight());
        child.setProfileImg(dto.getProfileImg());
        child.setSensitiveInfo(dto.getSensitiveInfo());
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
}