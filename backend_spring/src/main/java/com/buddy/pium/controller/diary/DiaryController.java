//package com.buddy.pium.controller.diary;
//
//import com.buddy.pium.dto.diary.DiaryRequest;
//import com.buddy.pium.service.diary.DiaryService;
//import lombok.RequiredArgsConstructor;
//import org.springframework.http.ResponseEntity;
//import org.springframework.security.core.Authentication;
//import org.springframework.web.bind.annotation.*;
//
//@RestController
//@RequiredArgsConstructor
//@RequestMapping("/diaries")
//public class DiaryController {
//
//    private final DiaryService diaryService;
//
//    @PostMapping
//    public ResponseEntity<Void> create(@RequestBody DiaryRequest request) {
//        Long mockMemberId = 1L; // 멤버 넣으면 -> (Long) auth.getPrincipal()
//        diaryService.createDiary(request, mockMemberId);
//        return ResponseEntity.ok().build();
//    }
//}
