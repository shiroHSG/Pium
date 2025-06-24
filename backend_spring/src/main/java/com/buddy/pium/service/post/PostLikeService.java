package com.buddy.pium.service.post;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostLike;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.PostLikeRepository;
import com.buddy.pium.repository.post.PostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PostLikeService {

    private final PostLikeRepository postLikeRepository;
    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    private final PostService postService;

    @Transactional
    public boolean toggleLike(Long postId, Member member) {
        Post post = postService.validatePost(postId);
        Optional<PostLike> existing = postLikeRepository.findByPostAndMember(post, member);

        if (existing.isPresent()) {
            postLikeRepository.delete(existing.get());
            return false;
        } else {
            postLikeRepository.save(PostLike.builder()
                    .post(post)
                    .member(member)
                    .build());
            return true;
        }
    }

    public long countLikes(Long postId) {
        Post post = postService.validatePost(postId);
        return postLikeRepository.countByPost(post);
    }
}