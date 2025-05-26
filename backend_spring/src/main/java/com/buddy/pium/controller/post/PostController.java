package com.buddy.pium.controller.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.service.post.PostService;
import lombok.RequiredArgsConstructor;
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
        // Long memberId = (Long) auth.getPrincipal();  이걸로 다시 바꿀것
        // postService.create(dto, memberId); 밑에는 사용자가 없어서 임의로 한것
        // return ResponseEntity.ok().build();
    public ResponseEntity<Void> create(@RequestBody PostRequest dto) {
        Long mockMemberId = 1L;
        postService.create(dto, mockMemberId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<PostResponse> get(@PathVariable Long id) {
        return ResponseEntity.ok(postService.get(id));
    }

    @GetMapping
    public ResponseEntity<List<PostResponse>> getAll(@RequestParam String category) {
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
}
