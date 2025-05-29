package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.PostCommentRequest;
import com.buddy.pium.dto.post.PostCommentResponse;
import com.buddy.pium.entity.member.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostComment;
import com.buddy.pium.repository.member.MemberRepository;
import com.buddy.pium.repository.post.PostCommentRepository;
import com.buddy.pium.repository.post.PostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostCommentService {

    private final PostCommentRepository postCommentRepository;
    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    public void create(Long postId, Long memberId, PostCommentRequest dto) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        PostComment comment = PostComment.builder()
                .post(post)
                .member(member)
                .content(dto.getContent())
                .build();

        postCommentRepository.save(comment);
    }

    public List<PostCommentResponse> getComments(Long postId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        return postCommentRepository.findByPost(post)
                .stream()
                .map(c -> PostCommentResponse.builder()
                        .id(c.getId())
                        .content(c.getContent())
                        .writer(c.getMember().getNickname())
                        .createdAt(c.getCreatedAt().toString())
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void update(Long commentId, Long memberId, PostCommentRequest dto) {
        PostComment comment = postCommentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("댓글 없음"));

        if (!comment.getMember().getId().equals(memberId)) {
            throw new RuntimeException("수정 권한 없음");
        }

        comment.setContent(dto.getContent());
    }

    @Transactional
    public void delete(Long commentId, Long memberId) {
        PostComment comment = postCommentRepository.findById(commentId)
                .orElseThrow(() -> new RuntimeException("댓글 없음"));

        if (!comment.getMember().getId().equals(memberId)) {
            throw new RuntimeException("삭제 권한 없음");
        }

        postCommentRepository.delete(comment);
    }
}
