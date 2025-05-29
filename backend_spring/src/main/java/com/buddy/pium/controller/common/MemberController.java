package com.buddy.pium.controller.common;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.MemberService;
import com.buddy.pium.util.JwtUtil; // ✅ 추가: JwtUtil import
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus; // ✅ 추가
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.security.core.Authentication; // ✅ 추가

import java.util.List;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final JwtUtil jwtUtil; // ✅ 추가: JWT 유틸 주입

    @GetMapping("/{id}")
    public ResponseEntity<Member> getById(@PathVariable Long id) {
        return memberService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/add")
    public ResponseEntity<Member> create(@RequestBody Member member) {
        return ResponseEntity.ok(memberService.save(member));
    }

    @GetMapping
    public ResponseEntity<List<Member>> getAll() {
        return ResponseEntity.ok(memberService.findAll());
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        memberService.delete(id);
        return ResponseEntity.noContent().build();
    }

//    @PostMapping("/edit/{id}")
//    public ResponseEntity<Member> updateMember(@PathVariable Long id, @RequestBody Member updatedMember) {
    @PostMapping("/edit")
    public ResponseEntity<Member> updateMember(@RequestBody Member updatedMember, Authentication authentication) {
        Long id = (Long) authentication.getPrincipal();
        Optional<Member> memberOptional = memberService.findById(id);
        if (memberOptional.isPresent()) {
            Member member = memberOptional.get();

            // ✅ 수정: null 아닌 필드만 업데이트
            if (updatedMember.getUsername() != null) member.setUsername(updatedMember.getUsername());
            if (updatedMember.getNickname() != null) member.setNickname(updatedMember.getNickname());
            if (updatedMember.getEmail() != null) member.setEmail(updatedMember.getEmail());
            if (updatedMember.getPassword() != null) member.setPassword(updatedMember.getPassword());
            if (updatedMember.getAddress() != null) member.setAddress(updatedMember.getAddress());
            if (updatedMember.getBirth() != null) member.setBirth(updatedMember.getBirth());
            if (updatedMember.getPhoneNumber() != null) member.setPhoneNumber(updatedMember.getPhoneNumber());
            if (updatedMember.getProfileImage() != null) member.setProfileImage(updatedMember.getProfileImage());
            if (updatedMember.getMateInfo() != null) member.setMateInfo(updatedMember.getMateInfo());

            return ResponseEntity.ok(memberService.save(member));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @GetMapping("/me")
    public ResponseEntity<Member> getById(Authentication authentication) {
        Long id = (Long) authentication.getPrincipal();
        return memberService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // ✅ 추가: 로그인 API (JWT 토큰 발급)
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> loginRequest) {
        String email = loginRequest.get("email");
        String password = loginRequest.get("password");

        Optional<Member> memberOptional = memberService.findByEmail(email);

        if (memberOptional.isPresent()) {
            Member member = memberOptional.get();

            // ✅ 평문 비밀번호와 암호화된 비밀번호 비교
            if (memberService.verifyPassword(password, member.getPassword())) {
                String token = jwtUtil.generateToken(member.getId(), member.getNickname());
                return ResponseEntity.ok(Map.of("token", token));
            }
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("Invalid email or password");
    }
}
