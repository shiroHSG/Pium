package com.buddy.pium.service.diary;

import com.buddy.pium.dto.diary.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.diary.Diary;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.diary.DiaryRepository;
import com.buddy.pium.service.FileUploadService;
import com.buddy.pium.service.common.ChildService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final MemberRepository memberRepository;
    private final ChildRepository childRepository;

    private final ChildService childService;
    private final FileUploadService fileUploadService;

    public void create(DiaryRequestDto dto, Member member, MultipartFile image) {
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "diaries"); // 파일 저장 후 URL 리턴
        }

        Child child = childService.validateChild(dto.getChildId(), member);

        Diary diary = Diary.builder()
                .member(member)
                .child(child)
                .content(dto.getContent())
                .imageUrl(imageUrl)
                .build();

        diaryRepository.save(diary);
    }

    public DiaryResponseDto get(Long id) {
        Diary diary = diaryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("일지 없음"));
        return DiaryResponseDto.from(diary);
    }

    public List<DiaryResponseDto> getAllByChild(Long childId, Member member) {
        Child child = childService.validateChild(childId, member);

        return diaryRepository.findByChildOrderByCreatedAtDesc(child).stream()
                .map(DiaryResponseDto::from)
                .toList();
    }

    public void updateDiary(Long diaryId, DiaryUpdateDto dto, Member member, MultipartFile image ) {
        Diary diary = validateDiary(diaryId, member);

        if (image != null && !image.isEmpty()) {
            if (member.getProfileImageUrl() != null) {
                fileUploadService.delete(member.getProfileImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "diaries");
            diary.setImageUrl(imageUrl);
        }

        if (dto.getContent() != null) diary.setContent(dto.getContent());

        diaryRepository.save(diary);
    }

    public void delete(Long diaryId, Member member) {
        Diary diary = validateDiary(diaryId, member);
        if (diary.getImageUrl() != null) {
            fileUploadService.delete(diary.getImageUrl());
        }
        diaryRepository.delete(diary);
    }

    public Diary validateDiary(Long diaryId, Member member) {
        Diary diary = diaryRepository.findById(diaryId)
                .orElseThrow(() -> new ResourceNotFoundException("일지 없음"));

        if (!diary.getMember().equals(member)) {
            throw new AccessDeniedException("수정 권한 없음");
        }
        return diary;
    }
}
