package com.buddy.pium.service.diary;

import com.buddy.pium.dto.diary.*;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.diary.Diary;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.diary.DiaryRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class DiaryService {

    private final DiaryRepository diaryRepository;
    private final MemberRepository memberRepository;
    private final ChildRepository childRepository;

    public void create(DiaryRequest request, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Child child = childRepository.findById(request.getChildId())
                .orElseThrow(() -> new RuntimeException("자녀 없음"));

        Diary diary = Diary.builder()
                .member(member)
                .child(child)
                .content(request.getContent())
                .imageUrl(request.getImageUrl())
                .build();

        diaryRepository.save(diary);
    }

    public DiaryResponse get(Long id) {
        Diary diary = diaryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("일지 없음"));
        return DiaryResponse.from(diary);
    }

    public List<DiaryResponse> getAllByChild(Long childId) {
        return diaryRepository.findByChildIdOrderByCreatedAtDesc(childId).stream()
                .map(DiaryResponse::from)
                .toList();
    }

    public void update(Long id, Long memberId, DiaryUpdateRequest request) {
        Diary diary = diaryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("일지 없음"));

        if (!diary.getMember().getId().equals(memberId)) {
            throw new RuntimeException("수정 권한 없음");
        }

        diary.setContent(request.getContent());
        diary.setImageUrl(request.getImageUrl());
    }

    public void delete(Long id, Long memberId) {
        Diary diary = diaryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("일지 없음"));

        if (!diary.getMember().getId().equals(memberId)) {
            throw new RuntimeException("삭제 권한 없음");
        }

        diaryRepository.delete(diary);
    }
}
