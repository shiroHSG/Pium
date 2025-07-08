package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Member;

import jakarta.validation.constraints.NotBlank;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.Optional;

public interface MemberRepository extends JpaRepository<Member, Long> {

    // 이메일로 사용자 조회 (로그인용)
    Optional<Member> findByEmail(String email);

    // 이메일 중복 확인
    boolean existsByEmail(String email);

    boolean existsByNickname(@NotBlank(message = "닉네임을 입력하세요") String nickname);

    List<Member> findByNicknameContainingIgnoreCaseOrAddressContainingIgnoreCase(String nickname, String address);



}
