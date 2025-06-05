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

    @PostMapping
    // public ResponseEntity<Void> create(@RequestBody PostRequest dto, Authentication auth) {
    //     Long memberId = (Long) auth.getPrincipal(); // 추후 로그인 연동 시 사용
    //     postService.create(dto, memberId);
    //     return ResponseEntity.ok().build();
    // }
    public ResponseEntity<?> create(@RequestBody PostRequest dto, Authentication authentication) {
        PostResponse response;
        Long senderId = (Long) authentication.getPrincipal();
        response = postService.create(dto, senderId);
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PostResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(postService.get(id));
    }

    @GetMapping
    public ResponseEntity<List<PostResponse>> getAll(@RequestParam String category, Authentication authentication) {
        return ResponseEntity.ok(postService.getAll(category));
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id,
                                       @RequestBody PostUpdateRequest dto,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        postService.update(id, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        postService.delete(id, memberId);
        return ResponseEntity.ok().build();
    }
    // /search?type=자유&keyword=123
    @GetMapping("/search")
    public ResponseEntity<Page<PostResponse>> search(
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String sort,
            Pageable pageable
    ) {
        if ("likes".equals(sort)) {
            return ResponseEntity.ok(postService.searchByLikes(pageable));
        }
        return ResponseEntity.ok(postService.search(type, keyword, pageable));
    }
}
