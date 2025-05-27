package com.buddy.pium.controller.post;

import com.buddy.pium.dto.post.PostCommentRequest;
import com.buddy.pium.dto.post.PostCommentResponse;
import com.buddy.pium.service.post.PostCommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
// 나중에 주석 제거
// import org.springframework.security.core.Authentication;
// import com.buddy.pium.security.MemberDetailsImpl;

@RestController
@RequiredArgsConstructor
@RequestMapping("/posts")
public class PostCommentController {

    private final PostCommentService postCommentService;

    @PostMapping("/{postId}/comments")
    public ResponseEntity<Void> create(@PathVariable Long postId,
                                       @RequestBody PostCommentRequest dto /*, Authentication auth */) {
        Long memberId = 1L;
        // 나중에 바꿀것
        // Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        // MemberDetailsImpl userDetails = (MemberDetailsImpl) auth.getPrincipal();
        // Long memberId = userDetails.getId();

        postCommentService.create(postId, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{postId}/comments")
    public ResponseEntity<List<PostCommentResponse>> getComments(@PathVariable Long postId) {
        return ResponseEntity.ok(postCommentService.getComments(postId));
    }

    @PutMapping("/comments/{commentId}")
    public ResponseEntity<Void> update(@PathVariable Long commentId,
                                       @RequestBody PostCommentRequest dto) {
        Long memberId = 1L;
        postCommentService.update(commentId, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void> delete(@PathVariable Long commentId) {
        Long memberId = 1L;
        postCommentService.delete(commentId, memberId);
        return ResponseEntity.ok().build();
    }
}
