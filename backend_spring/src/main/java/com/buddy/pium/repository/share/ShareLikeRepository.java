package com.buddy.pium.repository.share;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.entity.share.ShareLike;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ShareLikeRepository extends JpaRepository<ShareLike, Long> {

    // 특정 나눔글을 특정 멤버가 좋아요 눌렀는지
    Optional<ShareLike> findByMemberAndShare(Member member, Share share);

    // 특정 나눔글+멤버 조합의 좋아요 개수 (보통 0 또는 1)
    @Query("SELECT COUNT(sl) FROM ShareLike sl WHERE sl.share = :share AND sl.member = :member")
    Long countByShareAndMember(@Param("share") Share share, @Param("member") Member member);

    // 특정 나눔글의 전체 좋아요 개수
    Long countByShare(Share share);

    // 내가 좋아요 누른 모든 ShareLike (최신순 지원)
    List<ShareLike> findByMemberOrderByIdDesc(Member member);

}
