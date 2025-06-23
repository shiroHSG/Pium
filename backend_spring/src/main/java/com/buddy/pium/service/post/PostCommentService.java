package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.PostCommentRequest;
import com.buddy.pium.dto.post.PostCommentResponse;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostComment;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.PostCommentRepository;
import com.buddy.pium.repository.post.PostRepository;
import com.buddy.pium.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
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

    private final PostService postService;
    private final NotificationService notificationService;

    public void create(Long postId, Member member, PostCommentRequest dto) {
        Post post = postService.validatePostOwner(postId, member);

        PostComment comment = PostComment.builder()
                .post(post)
                .member(member)
                .content(dto.getContent())
                .build();

        // 알림 전송 (게시글 작성자에게)
        if (!member.equals(post.getMember())) { // 자기 자신 제외
            notificationService.sendNotification(
                    post.getMember().getId(),
                    member.getNickname() + "님이 댓글을 남겼습니다.",
                    "COMMENT",
                    "POST",
                    post.getId()
            );
        }

        postCommentRepository.save(comment);
    }

    public List<PostCommentResponse> getComments(Long postId) {
        Post post = postService.validatePost(postId);

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
    public void update(Long commentId, Member member, PostCommentRequest dto) {
        PostComment comment = validateCommentOwner(commentId, member);
        comment.setContent(dto.getContent());
    }

    @Transactional
    public void delete(Long commentId, Member member) {
        PostComment comment = validateCommentOwner(commentId, member);
        postCommentRepository.delete(comment);
    }

    public PostComment validateCommentOwner(Long commentId, Member member) {
        PostComment comment = postCommentRepository.findById(commentId)
                .orElseThrow(() -> new ResourceNotFoundException("댓글이 없습니다."));
        if (!comment.getMember().equals(member)) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return comment;
    }
}
