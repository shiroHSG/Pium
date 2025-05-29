package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.entity.member.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.repository.member.MemberRepository;
import com.buddy.pium.repository.post.PostRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    public void create(PostRequest dto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Post post = Post.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .category(dto.getCategory())
                .postImg(dto.getPostImg())
                .member(member)
                .build();

        postRepository.save(post);
    }

    public PostResponse get(Long id) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        post.setViewCount(post.getViewCount() + 1);
        postRepository.save(post);

        return toResponse(post);
    }

    public List<PostResponse> getAll(String category) {
        return postRepository.findAllByCategory(category).stream()
                .map(this::toResponse)
                .toList();
    }

    public void update(Long postId, Long memberId, PostUpdateRequest dto) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!post.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setPostImg(dto.getPostImg());
    }

    public void delete(Long postId, Long memberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!post.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        postRepository.delete(post);
    }

    public Page<PostResponse> search(String type, String keyword, Pageable pageable) {
        Page<Post> posts;

        if (type == null || keyword == null || keyword.isBlank()) {
            posts = postRepository.findAll(pageable);
        } else {
            switch (type) {
                case "title" -> posts = postRepository.findByTitleContaining(keyword, pageable);
                case "content" -> posts = postRepository.findByContentContaining(keyword, pageable);
                case "writer" -> posts = postRepository.findByWriterNickname(keyword, pageable);
                default -> throw new IllegalArgumentException("유효하지 않은 검색 타입입니다.");
            }
        }

        return posts.map(this::toResponse);
    }

    public Page<PostResponse> searchByLikes(Pageable pageable) {
        return postRepository.findAllByOrderByLikeCountDesc(pageable)
                .map(this::toResponse);
    }

    private PostResponse toResponse(Post post) {
        return new PostResponse(
                post.getId(),
                post.getTitle(),
                post.getContent(),
                post.getCategory(),
                post.getPostImg(),
                post.getMember().getNickname(),
                post.getViewCount() != null ? post.getViewCount() : 0,
                post.getCreatedAt()
        );
    }
}
