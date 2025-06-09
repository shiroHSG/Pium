//package com.buddy.pium.service.diary;
//
//import com.buddy.pium.dto.diary.DiaryRequest;
//import com.buddy.pium.entity.child.Child;
//import com.buddy.pium.entity.diary.Diary;
//import com.buddy.pium.entity.member.Member;
//import com.buddy.pium.repository.child.ChildRepository;
//import com.buddy.pium.repository.diary.DiaryRepository;
//import com.buddy.pium.repository.member.MemberRepository;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//public class DiaryService {
//
//    private final DiaryRepository diaryRepository;
//    private final MemberRepository memberRepository;
//    private final ChildRepository childRepository;
//
//    public void createDiary(DiaryRequest request, Long memberId) {
//        Member member = memberRepository.findById(memberId)
//                .orElseThrow(() -> new RuntimeException("회원 없음"));
//
//        Child child = childRepository.findById(request.getChildId())
//                .orElseThrow(() -> new RuntimeException("아이 없음"));
//
//        Diary diary = Diary.builder()
//                .member(member)
//                .child(child)
//                .content(request.getContent())
//                .imageUrl(request.getImageUrl())
//                .build();
//
//        diaryRepository.save(diary);
//    }
//}
