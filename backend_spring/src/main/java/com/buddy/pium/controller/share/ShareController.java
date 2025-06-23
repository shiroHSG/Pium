package com.buddy.pium.controller.share;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.share.ShareRequestDto;
import com.buddy.pium.dto.share.ShareResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.share.ShareService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/shares")
public class ShareController {

    private final ShareService shareService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createShare(
            @RequestPart("shareData") String shareDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            ShareRequestDto dto = mapper.readValue(shareDataJson, ShareRequestDto.class);

            shareService.create(dto, member, image);

            return ResponseEntity.ok(Map.of("message", "나눔 글 등록이 완료되었습니다."));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @GetMapping("/{shareId}")
    public ResponseEntity<ShareResponseDto> get(@PathVariable Long shareId,
                                                @CurrentMember Member member) {
        return ResponseEntity.ok(shareService.get(shareId));
    }

    @GetMapping
    public ResponseEntity<List<ShareResponseDto>> getAll(
            @CurrentMember Member member,
            @RequestParam(value = "category", required = false) String category) {
        if (category != null && !category.isEmpty()) {
            return ResponseEntity.ok(shareService.getByCategory(category));
        } else {
            return ResponseEntity.ok(shareService.getAll());
        }
    }

    @PatchMapping(value = "/{shareId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateShare(
            @PathVariable Long shareId,
            @RequestPart("shareData") String shareDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            ShareRequestDto dto = mapper.readValue(shareDataJson, ShareRequestDto.class);

            shareService.updateShare(shareId, member, dto, image);
            return ResponseEntity.ok(Map.of("message", "나눔 글을 수정했습니다."));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Long id, @CurrentMember Member member) {
        shareService.delete(id, member);
        return ResponseEntity.ok(Map.of("message", "나눔 글을 삭제했습니다."));
    }
}
