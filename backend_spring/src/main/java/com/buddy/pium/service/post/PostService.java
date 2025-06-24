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

    public Page<PostResponseDto> search(String type, String keyword, Pageable pageable) {
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
    }
}