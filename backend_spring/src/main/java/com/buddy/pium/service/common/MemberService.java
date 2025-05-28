package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final BCryptPasswordEncoder passwordEncoder; // ✅ 주입

    public Member save(Member member) {
        if (member.getPassword() != null) {
            member.setPassword(passwordEncoder.encode(member.getPassword())); // ✅ 암호화
        }
        return memberRepository.save(member);
    }

    public Optional<Member> findById(Long id) {
        return memberRepository.findById(id);
    }

    public Optional<Member> findByEmail(String email) {
        return memberRepository.findByEmail(email);
    }

    public boolean existsByEmail(String email) { return memberRepository.existsByEmail(email); }

    public List<Member> findAll() {
        return memberRepository.findAll();
    }

    public void delete(Long id) {
        memberRepository.deleteById(id);
    }

    // ✅ 로그인 시 비밀번호 검증용 메서드 추가 (선택적)
    public boolean verifyPassword(String rawPassword, String encodedPassword) {
        return passwordEncoder.matches(rawPassword, encodedPassword);
    }
}
