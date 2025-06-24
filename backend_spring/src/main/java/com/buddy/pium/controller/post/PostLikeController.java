package com.buddy.pium.controller.post;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.post.PostLikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/posts/{postId}/like")
@RequiredArgsConstructor
public class PostLikeController {

    private final PostLikeService postLikeService;

    // 좋아요 토글 API
    @PostMapping
    public ResponseEntity<?> toggleLike(@PathVariable Long postId,
                                        @CurrentMember Member member) {
        boolean liked = postLikeService.toggleLike(postId, member);
        return ResponseEntity.ok(liked ? "liked" : "unliked");
    }

    // 좋아유 수 반환
    @GetMapping
    public ResponseEntity<?> countLikes(@PathVariable Long postId,
                                        @CurrentMember Member member) {
        long count = postLikeService.countLikes(postId);
        return ResponseEntity.ok(count);
    }
}