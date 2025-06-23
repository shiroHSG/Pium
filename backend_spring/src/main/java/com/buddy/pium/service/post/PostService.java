// PostService.java
package com.buddy.pium.service.post;

import com.buddy.pium.dto.post.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.post.PostRepository;
import lombok.RequiredArgsConstructor;
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

    public PostResponse get(Long id, Long memberId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        post.increaseViewCount();
        postRepository.save(post);

        return PostResponse.from(post, memberId);
    }

    public List<PostResponse> getAll(Long memberId, String category, String type, String keyword) {
        List<Post> posts;

        boolean hasKeyword = keyword != null && !keyword.isBlank();
        boolean hasCategory = category != null && !category.isBlank();

        if (hasKeyword) {
            if (hasCategory) {
                switch (type) {
                    case "title":
                        posts = postRepository.findByCategoryAndTitleContaining(category, keyword);
                        break;
                    case "content":
                        posts = postRepository.findByCategoryAndContentContaining(category, keyword);
                        break;
                    case "title_content":
                        posts = postRepository.searchByCategoryAndTitleOrContent(category, keyword);
                        break;
                    case "author":
                        posts = postRepository.findByCategoryAndMemberNickname(category, keyword);
                        break;
                    default:
                        posts = postRepository.findByCategory(category);
                }
            } else {
                switch (type) {
                    case "title":
                        posts = postRepository.findByTitleContaining(keyword);
                        break;
                    case "content":
                        posts = postRepository.findByContentContaining(keyword);
                        break;
                    case "title_content":
                        posts = postRepository.searchByTitleOrContent(keyword);
                        break;
                    case "author":
                        if (hasCategory) {
                            posts = postRepository.findByCategoryAndMemberNickname(category, keyword);
                        } else {
                            posts = postRepository.findByMemberNickname(keyword);
                        }
                        break;

                    default:
                        posts = postRepository.findAll();
                }
            }
        } else {
            if (hasCategory) {
                posts = postRepository.findByCategory(category);
            } else {
                posts = postRepository.findAll();
            }
        }

        return posts.stream()
                .map(post -> PostResponse.from(post, memberId))
                .toList();
    }



    public PostResponse update(Long id, PostUpdateRequest dto, Long memberId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        if (!post.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        post.setTitle(dto.getTitle());
        post.setContent(dto.getContent());
        post.setCategory(dto.getCategory());
        post.setImgUrl(dto.getImgUrl());

        postRepository.save(post);

        return PostResponse.from(post, memberId);
    }

    public void delete(Long id, Long memberId) {
        Post post = postRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        if (!post.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        postRepository.delete(post);
    }
    public Post validatePostOwner(Long postId, Member member) {
        Post post = postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));

        if (!post.getMember().getId().equals(member.getId())) {
            throw new RuntimeException("권한 없음");
        }

        return post;
    }
    public Post validatePost(Long postId) {
        return postRepository.findById(postId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
    }


}
