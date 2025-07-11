package com.buddy.pium.repository.policy;

import com.buddy.pium.entity.policy.Policy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.repository.query.Param;
import org.springframework.data.domain.Pageable;

import java.util.List;

public interface PolicyRepository extends JpaRepository<Policy, Long> {

    @Query("select p from Policy p where p.title like %:keyword% or p.content like %:keyword%")
    Page<Policy> searchByKeyword(@Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT p FROM Policy p ORDER BY COALESCE(p.viewCount, 0) DESC")
    List<Policy> findTopPopularPolicies(Pageable pageable);

}
