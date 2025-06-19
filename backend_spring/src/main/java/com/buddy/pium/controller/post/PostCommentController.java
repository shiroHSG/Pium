package com.buddy.pium.controller.post;

import com.buddy.pium.dto.post.PostCommentRequest;
import com.buddy.pium.dto.post.PostCommentResponse;
import com.buddy.pium.service.post.PostCommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/posts")
public class PostCommentController {

    private final PostCommentService postCommentService;

    @PostMapping("/{postId}/comments")
    public ResponseEntity<Void> create(@PathVariable Long postId,
                                       @RequestBody PostCommentRequest dto,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        postCommentService.create(postId, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{postId}/comments")
    public ResponseEntity<List<PostCommentResponse>> getComments(@PathVariable Long postId) {
        return ResponseEntity.ok(postCommentService.getComments(postId));
    }

    @PutMapping("/comments/{commentId}")
    public ResponseEntity<Void> update(@PathVariable Long commentId,
                                       @RequestBody PostCommentRequest dto,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        postCommentService.update(commentId, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void> delete(@PathVariable Long commentId,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        postCommentService.delete(commentId, memberId);
        return ResponseEntity.ok().build();
    }
}
