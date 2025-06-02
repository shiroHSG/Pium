package com.buddy.pium.controller.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.service.common.MemberService;
import com.buddy.pium.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import com.buddy.pium.dto.common.LoginRequestDto;
import com.buddy.pium.dto.common.LoginResponseDto;


import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final JwtUtil jwtUtil;

    /**
     * 회원 가입
     */
    @PostMapping("/register")
    public ResponseEntity<MemberResponseDto> create(@RequestBody MemberRegisterDto registerDto) {
        MemberResponseDto responseDto = memberService.createMember(registerDto);
        return ResponseEntity.status(HttpStatus.CREATED).body(responseDto);
    }

    /**
     * 회원 정보 수정
     */
    @PostMapping("/edit")
    public ResponseEntity<MemberResponseDto> update(@RequestBody MemberUpdateDto updateDto,
                                                    Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        MemberResponseDto responseDto = memberService.updateMember(memberId, updateDto);
        return ResponseEntity.ok(responseDto);
    }

    /**
     * ID로 회원 조회
     */
    @GetMapping("/{id}")
    public ResponseEntity<MemberResponseDto> getById(@PathVariable Long id) {
        MemberResponseDto responseDto = memberService.getMemberById(id);
        return ResponseEntity.ok(responseDto);
    }

    /**
     * 전체 회원 조회
     */
    @GetMapping
    public ResponseEntity<List<MemberResponseDto>> getAll() {
        List<MemberResponseDto> responseList = memberService.getAllMembers();
        return ResponseEntity.ok(responseList);
    }

    /**
     * 회원 삭제
     */
    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        memberService.deleteMember(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * 내 정보 조회 (/me)
     */
    @GetMapping("/me")
    public ResponseEntity<MemberResponseDto> getMe(Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        MemberResponseDto responseDto = memberService.getMemberById(memberId);
        return ResponseEntity.ok(responseDto);
    }

    /**
     * 로그인 → AccessToken + RefreshToken 반환
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto loginRequest) {

        System.out.println("[Controller] 로그인 요청 들어옴");
        System.out.println("[Controller] 이메일: " + loginRequest.getEmail());
        System.out.println("[Controller] 비밀번호: " + loginRequest.getPassword());

        LoginResponseDto loginResponse = memberService.login(loginRequest);
        return ResponseEntity.ok(loginResponse);
    }

    // AccessToken 재발급
    @PostMapping("/reissue")
    public ResponseEntity<?> reissueAccessToken(@RequestHeader("Authorization") String bearerToken) {
        if (bearerToken == null || !bearerToken.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body("Refresh Token이 필요합니다.");
        }

        String refreshToken = bearerToken.substring(7);

        try {
            String newAccessToken = memberService.reissueAccessToken(refreshToken);
            return ResponseEntity.ok(Map.of("accessToken", newAccessToken));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(e.getMessage());
        }
    }

    @PostMapping("/logout")
    public ResponseEntity<?> logout(Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();

        memberService.logout(memberId);
        return ResponseEntity.ok(Map.of("message", "로그아웃 완료"));
    }

}
