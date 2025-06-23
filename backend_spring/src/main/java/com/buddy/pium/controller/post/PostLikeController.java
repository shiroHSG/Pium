package com.buddy.pium.controller.post;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.post.PostLikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/posts/{postId}/like")
public class PostLikeController {

    private final PostLikeService postLikeService;

    @PostMapping
    public ResponseEntity<Void> like(@PathVariable Long postId, @CurrentMember Member member) {
        postLikeService.like(postId, member.getId());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping
    public ResponseEntity<Void> unlike(@PathVariable Long postId, @CurrentMember Member member) {
        postLikeService.unlike(postId, member.getId());
        return ResponseEntity.ok().build();
    }
}
