package com.buddy.pium.controller.post;

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

    @PostMapping
    public ResponseEntity<String> toggleLike(@PathVariable Long postId,
                                             Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        boolean liked = postLikeService.toggleLike(postId, memberId);
        return liked
                ? ResponseEntity.ok("좋아요 추가됨")
                : ResponseEntity.ok("좋아요 취소됨");
    }

    @GetMapping
    public ResponseEntity<Long> countLikes(@PathVariable Long postId) {
        long count = postLikeService.countLikes(postId);
        return ResponseEntity.ok(count);
    }
}
