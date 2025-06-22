package com.buddy.pium.controller.common;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.MemberService;
import com.buddy.pium.util.JwtUtil;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import jakarta.validation.ConstraintViolation;
import jakarta.validation.Valid;
import jakarta.validation.Validator;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;
import java.util.Set;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;
    private final JwtUtil jwtUtil;

    @Autowired
    private Validator validator;

    /**
     * 회원 가입
     */
    @PostMapping(value = "/register", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> create(
            @RequestPart("memberData") String memberDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule());
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

            MemberRequestDto dto = mapper.readValue(memberDataJson, MemberRequestDto.class);

            // 수동 검증
            Set<ConstraintViolation<MemberRequestDto>> violations = validator.validate(dto);
            if (!violations.isEmpty()) {
                List<String> errors = violations.stream()
                        .map(ConstraintViolation::getMessage)
                        .toList();
                return ResponseEntity.badRequest().body(Map.of("message", "유효성 검사 실패", "errors", errors));
            }

            memberService.signUp(dto, image);

            return ResponseEntity.ok(Map.of("message", "회원가입 성공"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body(Map.of("message", "회원가입 실패: " + e.getMessage()));
        }
    }

    /**
     * 회원 정보 수정
     */
    @PatchMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> update(
            @RequestPart("memberData") String memberDataJson,
            @RequestPart(value = "image", required = false) MultipartFile image,
            @CurrentMember Member member
    ) {
        try {
            ObjectMapper mapper = new ObjectMapper();
            mapper.registerModule(new JavaTimeModule()); // LocalDate 대응
            mapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);

            MemberUpdateDto updateDto = mapper.readValue(memberDataJson, MemberUpdateDto.class);

            memberService.updateMember(member, updateDto, image);
            return ResponseEntity.ok(Map.of("message", "회원 정보 수정 완료"));
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).build();
        }
    }


    /**
     * ID로 회원 조회
     */
    @GetMapping("/users/{id}")
    public ResponseEntity<MemberResponseDto> getById(@PathVariable Long id) {
        MemberResponseDto responseDto = memberService.getMemberbyId(id);
        return ResponseEntity.ok(responseDto);
    }

    /**
     * 전체 회원 조회
     */
    @GetMapping("/users")
    public ResponseEntity<List<MemberResponseDto>> getAll() {
        List<MemberResponseDto> responseList = memberService.getAllMembers();
        return ResponseEntity.ok(responseList);
    }

    /**
     * 회원 삭제
     */
    @DeleteMapping("/delete/users/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        memberService.deleteMemberById(id);
        return ResponseEntity.noContent().build();
    }

    /**
     * 내 정보 조회 (/me)
     */
    @GetMapping
    public ResponseEntity<MemberResponseDto> getMe(@CurrentMember Member member) {
        MemberResponseDto responseDto = memberService.getMember(member);
        return ResponseEntity.ok(responseDto);
    }

    /**
     * 로그인 → AccessToken + RefreshToken 반환
     */
    @PostMapping("/login")
    public ResponseEntity<LoginResponseDto> login(@RequestBody LoginRequestDto loginRequest) {

        // 로그 출력용
        System.out.println("[Controller] 로그인 요청 들어옴");
        System.out.println("[Controller] 이메일: " + loginRequest.getEmail());
        System.out.println("[Controller] 비밀번호: " + loginRequest.getPassword());

        LoginResponseDto loginResponse = memberService.login(loginRequest);
        return ResponseEntity.ok(loginResponse);
    }

    /**
     * AccessToken 재발급
     */
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

    /**
     * 로그아웃
     */
    @PostMapping("/logout")
    public ResponseEntity<?> logout(@CurrentMember Member member) {

        // 로그 출력용
        System.out.println("[Controller] 로그아웃 요청 - member: " + member);

        memberService.logout(member);
        return ResponseEntity.ok(Map.of("message", "로그아웃 완료"));
    }

    // 회원 탈퇴 추가
    @DeleteMapping
    public ResponseEntity<?> deleteMember(@CurrentMember Member member) {
        try {
            memberService.deleteMember(member);
            return ResponseEntity.ok(Map.of("message", "회원 탈퇴가 완료되었습니다."));
        } catch (Exception e) {
            return ResponseEntity.status(500).body(Map.of("message", e.getMessage()));
        }
    }

    /**
     * 닉네임 또는 주소 기반 검색
     */
    // 검색의 경우 특정 리소스를 조회하는 것이 아닌, 조건에 해당하는 목록을 필터링 하는 것으로 RESTful API 원칙에 맞추기 위해 query 사용
    @GetMapping("/search")
    public ResponseEntity<List<MemberResponseDto>> searchMembers(@RequestParam String query) {
        List<MemberResponseDto> results = memberService.searchMembers(query);
        return ResponseEntity.ok(results);
    }
}
