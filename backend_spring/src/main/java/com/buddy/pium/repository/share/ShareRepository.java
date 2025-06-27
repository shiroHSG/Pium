package com.buddy.pium.repository.share;

import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.share.Share;
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






}
