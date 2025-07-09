package com.buddy.pium.service.diary;

import com.buddy.pium.dto.diary.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.diary.Diary;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.diary.DiaryRepository;
import com.buddy.pium.service.S3UploadService;
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
    private final S3UploadService s3UploadService;

    public void create(DiaryRequestDto dto, Member member, MultipartFile image) {
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = s3UploadService.upload(image, "diaries"); // 파일 저장 후 URL 리턴
        }

        Child child = childService.validateChild(dto.getChildId(), member);

        Diary diary = Diary.builder()
                .member(member)
                .child(child)
                .title(dto.getTitle())
                .content(dto.getContent())
                .publicContent(dto.getPublicContent())
                .published(dto.isPublished())
                .imageUrl(imageUrl)
                .build();

        diaryRepository.save(diary);
    }

    public DiaryResponseDto get(Long diaryId) {
        Diary diary = validateDiary(diaryId);
        return DiaryResponseDto.from(diary);
    }

    public List<DiaryResponseDto> getAllByChild(Long childId, Member member) {
        Child child = childService.validateChild(childId, member);

        return diaryRepository.findByChildOrderByCreatedAtDesc(child).stream()
                .map(DiaryResponseDto::from)
                .toList();
    }

    public void updateDiary(Long diaryId, DiaryUpdateDto dto, Member member) {
        Diary diary = validateDiaryOwner(diaryId, member);

        // ✅ 텍스트 필드 업데이트
        if (dto.getTitle() != null) diary.setTitle(dto.getTitle());
        if (dto.getContent() != null) diary.setContent(dto.getContent());
        if (dto.getPublicContent() != null) diary.setPublicContent(dto.getPublicContent());
        diary.setPublished(dto.getPublished());

        // ✅ 1. removeImage가 true이면 기존 이미지 삭제
        if (Boolean.TRUE.equals(dto.getRemoveImage())) {
            if (diary.getImageUrl() != null) {
                s3UploadService.delete(diary.getImageUrl());
                diary.setImageUrl(null);
            }
        }

        // ✅ 2. 새 이미지가 있을 경우 기존 이미지 덮어쓰기
        List<MultipartFile> images = dto.getImageFiles();
        if (images != null && !images.isEmpty()) {
            MultipartFile newImage = images.get(0);

            // 새 이미지 업로드 후 저장
            String imageUrl = s3UploadService.upload(newImage, "diaries");
            diary.setImageUrl(imageUrl);
        }

        diaryRepository.save(diary);
    }

    public void delete(Long diaryId, Member member) {
        Diary diary = validateDiaryOwner(diaryId, member);
        if (diary.getImageUrl() != null) {
            s3UploadService.delete(diary.getImageUrl());
        }
        diaryRepository.delete(diary);
    }

    public Diary validateDiaryOwner(Long diaryId, Member member) {
        Diary diary = validateDiary(diaryId);
        Member owner = diary.getMember();
        if (!owner.equals(member) && !owner.equals(member.getMateInfo())) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return diary;
    }

    public Diary validateDiary(Long diaryId) {
        return diaryRepository.findById(diaryId)
                .orElseThrow(() -> new ResourceNotFoundException("일지 없음"));
    }
}
