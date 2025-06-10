package com.buddy.pium.controller.diary;

import com.buddy.pium.dto.diary.*;
import com.buddy.pium.service.diary.DiaryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/diaries")
public class DiaryController {

    private final DiaryService diaryService;

    @PostMapping
    public ResponseEntity<Void> create(@RequestBody DiaryRequest request, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        diaryService.create(request, memberId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<DiaryResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(diaryService.get(id));
    }

    @GetMapping
    public ResponseEntity<List<DiaryResponse>> getAll(@RequestParam Long childId) {
        return ResponseEntity.ok(diaryService.getAllByChild(childId));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id,
                                       @RequestBody DiaryUpdateRequest request,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        diaryService.update(id, memberId, request);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        diaryService.delete(id, memberId);
        return ResponseEntity.ok().build();
    }
}
