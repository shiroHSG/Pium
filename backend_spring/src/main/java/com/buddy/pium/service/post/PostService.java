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

    // 게시글 등록
    public void create(PostRequestDto dto, Member member, MultipartFile image) {
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "posts");
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

    // 게시글 단건 조회(+조회수 증가)
    public PostResponseDto get(Long postId, Long memberId) {
        Post post = validatePost(postId);

        post.setViewCount(post.getViewCount() == null ? 1 : post.getViewCount() + 1);
        postRepository.save(post);

        return PostResponseDto.from(post, memberId);
    }

    // 전체/카테고리별 리스트
    public List<PostResponseDto> getAll(String category, Long memberId) {
        List<Post> posts;
        if (category == null || category.isBlank()) {
            posts = postRepository.findAll();
        } else {
            posts = postRepository.findByCategory(category);
        }
        return posts.stream()
                .map(post -> PostResponseDto.from(post, memberId))
                .toList();
    }

    // 게시글 수정
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
        post.setCategory(dto.getCategory());

        postRepository.save(post);
    }

    // 게시글 삭제
    public void delete(Long postId, Member member) {
        Post post = validatePostOwner(postId, member);
        if (post.getImageUrl() != null) {
            fileUploadService.delete(post.getImageUrl());
        }
        postRepository.delete(post);
    }

    // 검색 (예시: 제목, 내용, 작성자)
    public List<PostResponseDto> search(String type, String keyword, Long memberId) {
        List<Post> posts;

        if (type == null || keyword == null || keyword.isBlank()) {
            posts = postRepository.findAll();
        } else {
            switch (type) {
                case "title" -> posts = postRepository.findByTitleContaining(keyword);
                case "content" -> posts = postRepository.findByContentContaining(keyword);
                case "author" -> posts = postRepository.findByMemberNickname(keyword);
                case "address" -> posts = postRepository.findByMemberAddress(keyword);
                case "title_content" -> posts = postRepository.searchByTitleOrContent(keyword);
                default -> throw new IllegalArgumentException("유효하지 않은 검색 타입입니다.");
            }
        }
        return posts.stream().map(post -> PostResponseDto.from(post, memberId)).toList();
    }

    // ========== 유틸 ==========
    public Post validatePostOwner(Long postId, Member member) {
        Post post = validatePost(postId);
        if (!post.getMember().getId().equals(member.getId())) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return post;
    }
    public Post validatePost(Long postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new ResourceNotFoundException("글이 없습니다."));
    }
}
