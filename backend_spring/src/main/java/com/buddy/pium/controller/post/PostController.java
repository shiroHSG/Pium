package com.buddy.pium.controller.post;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.diary.DiaryRequestDto;
import com.buddy.pium.dto.diary.DiaryUpdateDto;
import com.buddy.pium.dto.post.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.post.PostService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/posts")
public class PostController {

    private final PostService postService;

    // 게시글 등록 (이미지 포함)
    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> createPost(
            @RequestPart("postData") String postDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            PostRequestDto dto = mapper.readValue(postDataJson, PostRequestDto.class);

            postService.create(dto, member, image);
            return ResponseEntity.ok(Map.of("message", "게시글 등록이 완료되었습니다."));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 게시글 단건 조회
    @GetMapping("/{postId}")
    public ResponseEntity<PostResponseDto> getPost(
            @PathVariable Long postId,
            @CurrentMember Member member
    ) {
        return ResponseEntity.ok(postService.get(postId, member.getId()));
    }

    // 게시글 전체/카테고리별 조회
    @GetMapping
    public ResponseEntity<List<PostResponseDto>> getAll(
            @RequestParam(required = false) String category,
            @CurrentMember Member member
    ) {
        return ResponseEntity.ok(postService.getAll(category, member.getId()));
    }

    // 게시글 수정 (이미지 포함, PATCH 방식 권장)
    @PatchMapping(value = "/{postId}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updatePost(
            @PathVariable Long postId,
            @RequestPart("postData") String postDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            PostUpdateDto dto = mapper.readValue(postDataJson, PostUpdateDto.class);

            postService.updatePost(postId, dto, member, image);
            return ResponseEntity.ok(Map.of("message", "게시글을 수정했습니다."));

        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    // 게시글 삭제
    @DeleteMapping("/{postId}")
    public ResponseEntity<?> deletePost(
            @PathVariable Long postId,
            @CurrentMember Member member
    ) {
        postService.delete(postId, member);
        return ResponseEntity.ok(Map.of("message", "게시글을 삭제했습니다."));
    }

    // 게시글 검색(제목/내용/작성자 등)
    @GetMapping("/search")
    public ResponseEntity<List<PostResponseDto>> searchPosts(
            @RequestParam String type,
            @RequestParam String keyword,
            @CurrentMember Member member
    ) {
        return ResponseEntity.ok(postService.search(type, keyword, member.getId()));
    }
}
