package com.buddy.pium.repository.post;

import com.buddy.pium.entity.post.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {

    List<Post> findAllByCategory(String category);

    List<Post> findAllPosts();

    Page<Post> findByTitleContaining(String keyword, Pageable pageable);

    Page<Post> findByContentContaining(String keyword, Pageable pageable);

    @Query("SELECT p FROM Post p WHERE p.member.nickname LIKE %:keyword%")
    Page<Post> findByWriterNickname(String keyword, Pageable pageable);

    Page<Post> findAllByOrderByLikeCountDesc(Pageable pageable);
}
