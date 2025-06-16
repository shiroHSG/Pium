package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChildService {

    private final ChildRepository childRepository;
    private final FileUploadService fileUploadService;

    public void addChild(ChildRequestDto dto, Member member, MultipartFile image) {
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "children"); // 파일 저장 후 URL 리턴
        }

        Child child = Child.builder()
                .member(member)
                .name(dto.getName())
                .birth(dto.getBirth())
                .gender(dto.getGender())
                .height(dto.getHeight())
                .weight(dto.getWeight())
                .profileImgUrl(imageUrl)
                .sensitiveInfo(dto.getSensitiveInfo())
                .build();

        childRepository.save(child);
    }

    public void deleteChild(Long childId, Member member) {
        Child child = validateChild(childId, member);
        childRepository.delete(child);
    }

    @Transactional
    public void updateChild(Long childId, ChildUpdateDto dto, Member member, MultipartFile image) {
        Child child = validateChild(childId, member);

        if (image != null && !image.isEmpty()) {
            if (member.getProfileImageUrl() != null) {
                fileUploadService.delete(member.getProfileImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "children");
            child.setProfileImgUrl(imageUrl);
        }
        if (dto.getName() != null) child.setName(dto.getName());
        if (dto.getBirth() != null) child.setBirth(dto.getBirth());
        if (dto.getGender() != null) child.setGender(dto.getGender());
        if (dto.getHeight() != null) child.setHeight(dto.getHeight());
        if (dto.getWeight() != null) child.setWeight(dto.getWeight());
        if (dto.getSensitiveInfo() != null) child.setSensitiveInfo(dto.getSensitiveInfo());

        childRepository.save(child);
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

    public Child validateChild(Long childId, Member member) {
        Child child = childRepository.findById(childId)
                .orElseThrow(() -> new ResourceNotFoundException("아이를 찾을 수 없습니다."));
        if (!child.getMember().equals(member)) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return child;
    }
}