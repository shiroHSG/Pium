package com.buddy.pium.repository.policy;

import com.buddy.pium.entity.policy.Policy;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface PolicyRepository extends JpaRepository<Policy, Long> {

    @Query("SELECT p FROM Policy p WHERE p.title LIKE %:keyword% OR p.content LIKE %:keyword%")
    List<Policy> searchByKeyword(String keyword);
}
