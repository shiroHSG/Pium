package com.buddy.pium.repository.post;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostLike;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface PostLikeRepository extends JpaRepository<PostLike, Long> {
    Optional<PostLike> findByPostAndMember(Post post, Member member);

    long countByPost(Post post);

    // 내가 좋아요 누른 모든 PostLike (최신순 지원용)
    List<PostLike> findByMemberOrderByIdDesc(Member member);
}
