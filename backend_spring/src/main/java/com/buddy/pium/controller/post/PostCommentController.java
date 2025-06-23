package com.buddy.pium.controller.post;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.dto.post.PostCommentRequestDto;
import com.buddy.pium.dto.post.PostCommentResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.post.PostCommentService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/posts")
public class PostCommentController {

    private final PostCommentService postCommentService;

    @PostMapping("/{postId}/comments")
    public ResponseEntity<Void> create(@PathVariable Long postId,
                                       @RequestBody PostCommentRequestDto dto,
                                       @CurrentMember Member member) {
        postCommentService.create(postId, member, dto);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{postId}/comments")
    public ResponseEntity<List<PostCommentResponseDto>> getComments(@PathVariable Long postId,
                                                                    @CurrentMember Member member) {
        return ResponseEntity.ok(postCommentService.getComments(postId));
    }

    @PutMapping("/comments/{commentId}")
    public ResponseEntity<Void> update(@PathVariable Long commentId,
                                       @RequestBody PostCommentRequestDto dto,
                                       @CurrentMember Member member) {
        postCommentService.update(commentId, member, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/comments/{commentId}")
    public ResponseEntity<Void> delete(@PathVariable Long commentId,
                                       @CurrentMember Member member) {
        postCommentService.delete(commentId, member);
        return ResponseEntity.ok().build();
    }
}
