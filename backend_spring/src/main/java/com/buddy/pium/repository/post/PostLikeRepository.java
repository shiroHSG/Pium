// PostLikeRepository.java
package com.buddy.pium.repository.post;

import com.buddy.pium.entity.post.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;

public interface PostLikeRepository extends JpaRepository<PostLike, Long> {
    boolean existsByPostIdAndMemberId(Long postId, Long memberId);

    void deleteByPostIdAndMemberId(Long postId, Long memberId);
}
