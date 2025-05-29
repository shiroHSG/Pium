package com.buddy.pium.repository.post;

import com.buddy.pium.entity.post.SharePost;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SharePostRepository extends JpaRepository<SharePost, Long> {
    Optional<SharePost> findById(Long postId);
}
