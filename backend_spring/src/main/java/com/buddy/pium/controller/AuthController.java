package com.buddy.pium.controller;

import com.buddy.pium.dto.LoginRequestDto;
import com.buddy.pium.entity.member.Member;
import com.buddy.pium.repository.MemberRepository;
import com.buddy.pium.util.JwtUtil;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final MemberRepository memberRepository;
    private final JwtUtil jwtUtil;

    public AuthController(MemberRepository memberRepository, JwtUtil jwtUtil) {
        this.memberRepository = memberRepository;
        this.jwtUtil = jwtUtil;
    }

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequestDto loginRequest) {
        Optional<Member> optionalMember = memberRepository.findByEmail(loginRequest.getEmail());

        if (optionalMember.isPresent()) {
            Member member = optionalMember.get();

            if (member.getPassword().equals(loginRequest.getPassword())) { // ⚠️ 실제 환경에서는 암호화 필요
                String token = jwtUtil.generateToken(member.getEmail());
                return ResponseEntity.ok().body(token);
            }
        }

        return ResponseEntity.status(401).body("Invalid email or password");
    }
}
