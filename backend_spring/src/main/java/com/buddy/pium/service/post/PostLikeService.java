// PostLikeService.java
package com.buddy.pium.service.post;

import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostLike;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.post.PostLikeRepository;
import com.buddy.pium.repository.post.PostRepository;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class PostLikeService {

    private final PostLikeRepository postLikeRepository;
    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    @Transactional
    public void like(Long postId, Long memberId) {
        if (postLikeRepository.existsByPostIdAndMemberId(postId, memberId)) {
            throw new RuntimeException("이미 좋아요를 눌렀습니다.");
        }

        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        PostLike postLike = PostLike.builder()
                .post(post)
                .member(member)
                .build();

        postLikeRepository.save(postLike);
    }

    @Transactional
    public void unlike(Long postId, Long memberId) {
        if (!postLikeRepository.existsByPostIdAndMemberId(postId, memberId)) {
            throw new RuntimeException("좋아요를 누르지 않았습니다.");
        }
        postLikeRepository.deleteByPostIdAndMemberId(postId, memberId);
    }
}
