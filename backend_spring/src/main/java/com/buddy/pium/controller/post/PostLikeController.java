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

    // 좋아요 토글 API
    @PostMapping
    public ResponseEntity<String> toggleLike(@PathVariable Long postId, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        boolean liked = postLikeService.toggleLike(postId, memberId);
        return liked ? ResponseEntity.ok("좋아요 추가됨") : ResponseEntity.ok("좋아요 취소됨");
    }

    // 좋아유 수 반환
    @GetMapping
    public ResponseEntity<?> countLikes(@PathVariable Long postId, Authentication auth) {
        long count = postLikeService.countLikes(postId);
        return ResponseEntity.ok(count);
    }
}
