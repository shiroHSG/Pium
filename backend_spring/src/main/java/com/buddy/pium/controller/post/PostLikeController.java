package com.buddy.pium.controller.post;

import com.buddy.pium.service.post.PostLikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

// 나중에 바꿀것!
// import org.springframework.security.core.Authentication;
// import org.springframework.security.core.context.SecurityContextHolder;
// import com.buddy.pium.security.MemberDetailsImpl;

@RestController
@RequestMapping("/posts/{postId}/like")
@RequiredArgsConstructor
public class PostLikeController {

    private final PostLikeService postLikeService;

    @PostMapping
    public ResponseEntity<String> toggleLike(@PathVariable Long postId /* , Authentication auth */) {
        // 테스트용
        Long memberId = 1L;

        // 나중에 JWT 로그인 적용시 바꿀것
        /*
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        MemberDetailsImpl userDetails = (MemberDetailsImpl) auth.getPrincipal();
        Long memberId = userDetails.getId();
        */

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
