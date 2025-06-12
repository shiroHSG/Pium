package com.buddy.pium.repository.share;

import com.buddy.pium.entity.share.Share;
import com.buddy.pium.entity.share.ShareLike;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

public interface ShareLikeRepository extends JpaRepository<ShareLike, Long> {
    Optional<ShareLike> findByMemberAndShare(Member member, Share share);

    @Query("SELECT COUNT(sl) FROM ShareLike sl WHERE sl.share = :share AND sl.member = :member")
    Long countByShareAndMember(@Param("share") Share share, @Param("member") Member member);

    Long countByShare(Share share);
}
