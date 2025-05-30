package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    Optional<Member> findByEmail(String email);

//    Optional<Member> findById(Long id);

    boolean existsByEmail(String email);
}
