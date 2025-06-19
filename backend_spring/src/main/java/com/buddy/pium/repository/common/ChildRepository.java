package com.buddy.pium.repository.common;

import com.buddy.pium.dto.common.ChildResponseDto;
import com.buddy.pium.entity.common.Child;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface ChildRepository extends JpaRepository<Child, Long> {
    List<Child> findByMemberId(Long memberId);
    List<Child> findByMemberIdIn(List<Long> memberIds);

    Optional<Child> findByIdAndMemberId(Long childId, Long memberId);
}