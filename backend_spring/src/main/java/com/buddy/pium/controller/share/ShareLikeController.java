package com.buddy.pium.controller.share;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.share.ShareLikeService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/shares/{postId}/like")
public class ShareLikeController {

    private final ShareLikeService shareLikeService;

    // 좋아요 토글 API
    @PostMapping
    public ResponseEntity<String> toggleLike(@PathVariable Long postId,
                                             @CurrentMember Member member) {
        boolean liked = shareLikeService.toggleLike(postId, member);
        return ResponseEntity.ok(liked ? "liked" : "unliked");
    }

    // 좋아유 수 반환
    @GetMapping
    public ResponseEntity<?> countLikes(@PathVariable Long postId,
                                        @CurrentMember Member member) {
        Long likes = shareLikeService.countLikes(postId);
        return ResponseEntity.ok(likes);
    }
}
