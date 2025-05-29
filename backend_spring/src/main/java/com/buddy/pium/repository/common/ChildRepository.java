package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Child;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ChildRepository extends JpaRepository<Child, Long> {
    List<Child> findByNameContaining(String keyword); // 이름 검색 기능
}
