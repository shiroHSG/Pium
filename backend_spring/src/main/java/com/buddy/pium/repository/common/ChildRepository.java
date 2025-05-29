package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Child;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ChildRepository extends JpaRepository<Child, Long> {

    // 특정 member_id의 자녀 목록 조회
    List<Child> findByMemberId(Long memberId);
}
