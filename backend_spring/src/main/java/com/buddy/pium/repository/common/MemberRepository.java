package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {
    // 로그인 사용자 조회용
    Optional<Member> findByEmail(String email);

    // 사용자 정보 조회용
    Optional<Member> findById(Long id);

    // 회원가입 시 중복 체크 : 추후 필요시 전화번호 중복여부 등 추가
    boolean existsByEmail(String email);
}
