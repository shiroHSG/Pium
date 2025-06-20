package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.PostRepository;
import com.buddy.pium.service.FileUploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;

@Service
@RequiredArgsConstructor
public class PostService {

    private final PostRepository postRepository;
    private final MemberRepository memberRepository;

    private final FileUploadService fileUploadService;

    public void create(PostRequestDto dto, Member member, MultipartFile image) {
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "posts"); // 파일 저장 후 URL 리턴
        }

        Post post = Post.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .category(dto.getCategory())
                .member(member)
                .imageUrl(imageUrl)
                .viewCount(0L)
                .build();

        postRepository.save(post);
<<<<<<< HEAD

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
=======
    }

    public PostResponseDto get(Long postId) {
        Post post = validatePost(postId);

        post.setViewCount(post.getViewCount() + 1);
        postRepository.save(post);

        return PostResponseDto.from(post);
    }

    public List<PostResponseDto> getAll(String category) {
        return postRepository.findAllByCategory(category).stream()
                .map(PostResponseDto::from)
                .toList();
    }

    public void updatePost(Long postId, PostUpdateDto dto, Member member, MultipartFile image) {
        Post post = validatePostOwner(postId, member);
>>>>>>> 97b761ed9afd878756cbc460c640dc0dc6bf36f2

        if (image != null && !image.isEmpty()) {
            if (post.getImageUrl() != null) {
                fileUploadService.delete(post.getImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "posts");
            post.setImageUrl(imageUrl);
        }

        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
    }

    public void delete(Long postId, Member member) {
        Post post = validatePostOwner(postId, member);
        if (post.getImageUrl() != null) {
            fileUploadService.delete(post.getImageUrl());
        }
        postRepository.delete(post);
    }

<<<<<<< HEAD
    public Page<PostResponse> search(String type, String keyword, Pageable pageable, Long memberId) {
=======
    public Page<PostResponseDto> search(String type, String keyword, Pageable pageable) {
>>>>>>> 97b761ed9afd878756cbc460c640dc0dc6bf36f2
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
<<<<<<< HEAD
        return posts.map(post -> PostResponse.from(post, memberId));
    }

    public Page<PostResponse> searchByLikes(Pageable pageable, Long memberId) {
        return postRepository.findAllOrderByLikeCountDesc(pageable)
                .map(post -> PostResponse.from(post, memberId));
=======

        return posts.map(PostResponseDto::from);
    }

    public Page<PostResponseDto> searchByLikes(Pageable pageable) {
        return postRepository.findAllOrderByLikeCountDesc(pageable)
                .map(PostResponseDto::from);
    }

    public Post validatePostOwner(Long postId, Member member) {
        Post post = validatePost(postId);
        if (!post.getMember().equals(member)) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return post;
    }
    public Post validatePost(Long postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("글이 없습니다."));
>>>>>>> 97b761ed9afd878756cbc460c640dc0dc6bf36f2
    }
}
