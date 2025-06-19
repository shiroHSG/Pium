package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.repository.common.MemberRepository;
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

    public PostResponse create(PostRequest dto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Post post = Post.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .category(dto.getCategory())
                .imgUrl(dto.getImgUrl())
                .member(member)
                .viewCount(0L)
                .build();

        postRepository.save(post);

        return PostResponse.from(post, memberId);
    }

    public PostResponse get(Long id, Long memberId) { // memberId 추가!
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("글 없음"));
        post.setViewCount(post.getViewCount() + 1);
        postRepository.save(post);
        return PostResponse.from(post, memberId);
    }

    // **전체 글 반환 로직**
    public List<PostResponse> getAll(String category, Long memberId) {
        if (category == null || category.isBlank()) {
            return postRepository.findAll().stream()
                    .map(post -> PostResponse.from(post, memberId))
                    .toList();
        }
        return postRepository.findAllByCategory(category).stream()
                .map(post -> PostResponse.from(post, memberId))
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
        post.setImgUrl(dto.getImgUrl());
    }

    public void delete(Long postId, Long memberId) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!post.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        postRepository.delete(post);
    }

    public Page<PostResponse> search(String type, String keyword, Pageable pageable, Long memberId) {
        Page<Post> posts;

        if (type == null || keyword == null || keyword.isBlank()) {
            posts = postRepository.findAll(pageable);
        } else {
            switch (type) {
                case "title" -> posts = postRepository.findByTitleContaining(keyword, pageable);
                case "content" -> posts = postRepository.findByContentContaining(keyword, pageable);
                case "writer", "author" -> posts = postRepository.findByWriterNickname(keyword, pageable); // 이 줄 추가!
                default -> throw new IllegalArgumentException("유효하지 않은 검색 타입입니다.");
            }
        }
        return posts.map(post -> PostResponse.from(post, memberId));
    }

    public Page<PostResponse> searchByLikes(Pageable pageable, Long memberId) {
        return postRepository.findAllOrderByLikeCountDesc(pageable)
                .map(post -> PostResponse.from(post, memberId));
    }
}
