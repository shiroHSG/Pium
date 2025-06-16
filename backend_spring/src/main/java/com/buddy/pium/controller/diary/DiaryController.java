package com.buddy.pium.controller.diary;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.common.ChildUpdateDto;
import com.buddy.pium.dto.diary.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.diary.DiaryService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/diaries")
public class DiaryController {

    private final DiaryService diaryService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createDiary(
            @RequestPart("diaryData") String diaryDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            DiaryRequestDto dto = mapper.readValue(diaryDataJson, DiaryRequestDto.class);

            diaryService.create(dto, member, image);

            return ResponseEntity.ok(Map.of("message", "육아 일지 등록이 완료되었습니다."));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/{diaryId}")
    public ResponseEntity<DiaryResponseDto> get(@PathVariable Long diaryId, @CurrentMember Member member) {
        return ResponseEntity.ok(diaryService.get(diaryId));
    }

    @GetMapping
    public ResponseEntity<List<DiaryResponseDto>> getAll(@RequestParam Long childId,
                                                         @CurrentMember Member member) {
        return ResponseEntity.ok(diaryService.getAllByChild(childId, member));
    }

    @PatchMapping(value = "/{diaryId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateDiary(
            @PathVariable Long diaryId,
            @RequestPart("diaryData") String diaryDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            DiaryUpdateDto dto = mapper.readValue(diaryDataJson, DiaryUpdateDto.class);

            diaryService.updateDiary(diaryId, dto, member, image);
            return ResponseEntity.ok(Map.of("message", "육아 일지를 수정했습니다."));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{diaryId}")
    public ResponseEntity<?> delete(@PathVariable Long diaryId,
                                       @CurrentMember Member member) {
        diaryService.delete(diaryId, member);
        return ResponseEntity.ok(Map.of("message", "육아 일지 삭제 완료되었습니다."));
    }
}
