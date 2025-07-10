package com.buddy.pium.repository.share;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ShareRepository extends JpaRepository<Share, Long> {
    List<Share> findByCategory(String category);

    @Query("SELECT s FROM Share s WHERE " +
            "LOWER(s.title) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(s.member.nickname) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
            "OR LOWER(s.member.address) LIKE LOWER(CONCAT('%', :keyword, '%'))")
    List<Share> searchByKeyword(@Param("keyword") String keyword);

    // 내가 쓴 나눔글 (최신순, 페이징)
    Page<Share> findByMemberOrderByCreatedAtDesc(Member member, Pageable pageable);

    // id 리스트로 Share 찾기 (좋아요 누른 글, 페이징)
    Page<Share> findByIdInOrderByCreatedAtDesc(List<Long> shareIds, Pageable pageable);
}
