package com.buddy.pium.service.post;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostLike;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.PostLikeRepository;
import com.buddy.pium.repository.post.PostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PostLikeService {

    private final PostLikeRepository postLikeRepository;
    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    public boolean toggleLike(Long postId, Long memberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Optional<PostLike> existing = postLikeRepository.findByPostAndMember(post, member);

        if (existing.isPresent()) {
            postLikeRepository.delete(existing.get());
            return false; // 좋아요 취소
        } else {
            postLikeRepository.save(PostLike.builder()
                    .post(post)
                    .member(member)
                    .build());
            return true; // 좋아요 추가
        }
    }

    public long countLikes(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
        return postLikeRepository.countByPost(post);
    }
}
