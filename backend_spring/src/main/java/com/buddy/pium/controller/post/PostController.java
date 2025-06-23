package com.buddy.pium.controller.post;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.post.PostResponse;
import com.buddy.pium.dto.post.PostUpdateRequest;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.post.PostService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import com.buddy.pium.dto.post.PostRequest;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/posts")
public class PostController {

    private final PostService postService;

    @PostMapping
    public ResponseEntity<PostResponse> create(@RequestBody PostRequest dto, @CurrentMember Member member) {
        PostResponse response = postService.create(dto, member.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping("/{id}")
    public ResponseEntity<PostResponse> get(@PathVariable Long id, @CurrentMember Member member) {
        PostResponse response = postService.get(id, member.getId());
        return ResponseEntity.ok(response);
    }

    @GetMapping
    public ResponseEntity<List<PostResponse>> getAll(
            @CurrentMember Member member,
            @RequestParam(required = false) String category,
            @RequestParam(required = false) String type,
            @RequestParam(required = false) String keyword
    ) {
        List<PostResponse> responses = postService.getAll(member.getId(), category, type, keyword);
        return ResponseEntity.ok(responses);
    }


    @PutMapping("/{id}")
    public ResponseEntity<PostResponse> update(@PathVariable Long id, @RequestBody PostUpdateRequest dto, @CurrentMember Member member) {
        PostResponse response = postService.update(id, dto, member.getId());
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, @CurrentMember Member member) {
        postService.delete(id, member.getId());
        return ResponseEntity.ok().build();
    }
}
