package com.buddy.pium.controller.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.service.post.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/posts")
public class PostController {

    private final PostService postService;

    // 게시글 등록
    @PostMapping
    public ResponseEntity<PostResponse> create(@RequestBody PostRequest dto, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        PostResponse response = postService.create(dto, memberId);
        return ResponseEntity.ok(response);
    }


    // 게시글 전체 조회 (카테고리, 인증X 가능)
    @GetMapping
    public ResponseEntity<List<PostResponse>> getAll(
            @RequestParam(required = false) String category,
            Authentication auth
    ) {
        Long memberId = (auth != null && auth.getPrincipal() != null)
                ? (Long) auth.getPrincipal() : null;
        return ResponseEntity.ok(postService.getAll(category, memberId));
    }

    // 단일 게시글 조회 (인증O)
    @GetMapping("/{id}")
    public ResponseEntity<PostResponse> get(
            @PathVariable Long id,
            Authentication auth
    ) {
        Long memberId = (auth != null && auth.getPrincipal() != null)
                ? (Long) auth.getPrincipal() : null;
        return ResponseEntity.ok(postService.get(id, memberId));
    }

    // 게시글 수정
    @PutMapping("/{id}")
    public ResponseEntity<Void> update(
            @PathVariable Long id,
            @RequestBody PostUpdateRequest dto,
            Authentication auth
    ) {
        Long memberId = (Long) auth.getPrincipal();
        postService.update(id, memberId, dto);
        return ResponseEntity.ok().build();
    }

    // 게시글 삭제
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(
            @PathVariable Long id,
            Authentication auth
    ) {
        Long memberId = (Long) auth.getPrincipal();
        postService.delete(id, memberId);
        return ResponseEntity.ok().build();
    }

    // 게시글 검색(좋아요순 포함)
    @GetMapping("/search")
    public ResponseEntity<Page<PostResponse>> search(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort,
            Pageable pageable,
            Authentication auth
    ) {
        Long memberId = (auth != null && auth.getPrincipal() != null)
                ? (Long) auth.getPrincipal() : null;
        if ("likes".equals(sort)) {
            return ResponseEntity.ok(postService.searchByLikes(pageable, memberId));
        }
        return ResponseEntity.ok(postService.search(type, keyword, pageable, memberId));
    }
}
