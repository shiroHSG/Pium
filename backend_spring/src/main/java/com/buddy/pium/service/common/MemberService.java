package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.service.FileUploadService;
import com.buddy.pium.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

import java.time.Duration;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;
    private final BCryptPasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final TokenService tokenService; // Redis 연동

    private final FileUploadService fileUploadService;

    // 회원 생성
    public void signUp(MemberRequestDto dto, MultipartFile image) {
        if(memberRepository.existsByEmail(dto.getEmail())) {
            throw new IllegalArgumentException("이미 가입된 이메일입니다.");
        }

        if(memberRepository.existsByNickname(dto.getNickname())) {
            throw new IllegalArgumentException("이미 사용중인 닉네임입니다.");
        }
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "members"); // 파일 저장 후 URL 리턴
        }

        Member member = Member.builder()
                .email(dto.getEmail())
                .password(passwordEncoder.encode(dto.getPassword()))
                .username(dto.getUsername())
                .nickname(dto.getNickname())
                .phoneNumber(dto.getPhoneNumber())
                .address(dto.getAddress())
                .birth(dto.getBirth())
                .gender(dto.getGender())
                .profileImageUrl(imageUrl)
                .build();

        memberRepository.save(member);
    }

    // 회원 정보 수정
    @Transactional
    public void updateMember(Member member, MemberUpdateDto dto, MultipartFile image) {
        if (!member.getNickname().equals(dto.getNickname()) &&
                memberRepository.existsByNickname(dto.getNickname())) {
            throw new IllegalArgumentException("이미 사용중인 닉네임입니다.");
        }
        if (image != null && !image.isEmpty()) {
            if (member.getProfileImageUrl() != null) {
                fileUploadService.delete(member.getProfileImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "chatrooms");
            member.setProfileImageUrl(imageUrl);
        }

        if (dto.getUsername() != null) member.setUsername(dto.getUsername());
        if (dto.getNickname() != null) member.setNickname(dto.getNickname());
        if (dto.getPassword() != null) member.setPassword(passwordEncoder.encode(dto.getPassword())); // 비번 변경 시 암호화 필요
        if (dto.getPhoneNumber() != null) member.setPhoneNumber(dto.getPhoneNumber());
        if (dto.getAddress() != null) member.setAddress(dto.getAddress());
        if (dto.getBirth() != null) member.setBirth(dto.getBirth());
        if (dto.getGender() != null) member.setGender(dto.getGender());

        memberRepository.save(member);
    }

    public MemberResponseDto getMember(Member member) {
        return toResponseDto(member);
    }

    public MemberResponseDto getMemberbyId(Long memberId) {
        Member member = validateMember(memberId);

        return toResponseDto(member);
    }

    public List<MemberResponseDto> getAllMembers() {
        return memberRepository.findAll().stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    public void deleteMemberById(Long memberId) {
        Member member = validateMember(memberId);
        if (member.getProfileImageUrl() != null) {
            fileUploadService.delete(member.getProfileImageUrl());
        }
        memberRepository.deleteById(memberId);
    }

    public void deleteMember(Member member) {
        if (member.getProfileImageUrl() != null) {
            fileUploadService.delete(member.getProfileImageUrl());
        }
        memberRepository.delete(member);
    }

    public Optional<Member> findByEmail(String email) {
        return memberRepository.findByEmail(email);
    }

    public boolean existsByEmail(String email) {
        return memberRepository.existsByEmail(email);
    }

    // ✅ 로그인 및 토큰 발급 - 디버깅 로그 포함
    public LoginResponseDto login(LoginRequestDto dto) {
        System.out.println("[Service] 로그인 시도: " + dto.getEmail());

        Optional<Member> optional = memberRepository.findByEmail(dto.getEmail());
        if (optional.isPresent()) {
            Member member = optional.get();
            System.out.println("[Service] 사용자 존재함: " + member.getEmail());

            if (passwordEncoder.matches(dto.getPassword(), member.getPassword())) {
                System.out.println("[Service] 비밀번호 일치 → 토큰 발급 진행");

                // ✅ mateInfo 로그 확인
                System.out.println("[Service] member.getId(): " + member.getId());

                // ✅ 로그인 시 RefreshToken Redis에 저장
                String accessToken = jwtUtil.generateAccessToken(member.getId());
                String refreshToken = jwtUtil.generateRefreshToken(member.getId());

                // ✅ 발급된 토큰 로그 출력
                System.out.println("[Service] AccessToken: " + accessToken);
                System.out.println("[Service] RefreshToken: " + refreshToken);

                tokenService.saveRefreshToken(member.getId(), refreshToken, Duration.ofDays(7)); // Redis 저장

                memberRepository.save(member);

                System.out.println("[Service] 로그인 성공 → 토큰 저장 완료");

                return LoginResponseDto.builder()
                        .accessToken(accessToken)
                        .refreshToken(refreshToken)
                        .memberId(member.getId())
                        .build();
            } else {
                System.out.println("[Service] 비밀번호 불일치");
            }
        } else {
            System.out.println("[Service] 사용자 이메일 없음");
        }

        throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "이메일 또는 비밀번호가 일치하지 않습니다.");
    }

    private MemberResponseDto toResponseDto(Member member) {
        return MemberResponseDto.builder()
                .id(member.getId())
                .username(member.getUsername())
                .nickname(member.getNickname())
                .email(member.getEmail())
                .password("****")  // 🔐 마스킹
                .phoneNumber(member.getPhoneNumber())
                .address(member.getAddress())
                .birth(member.getBirth())
                .gender(member.getGender())
                .profileImageUrl(member.getProfileImageUrl())
                .mateInfo(member.getMateInfo())
                .refreshToken("****")  // 🔐 마스킹 또는 null
                .createdAt(member.getCreatedAt())  // 🔄 변환
                .updatedAt(member.getUpdatedAt())  // 🔄 변환
                .build();
    }

    // AccessToken 재발급
    public String reissueAccessToken(String refreshToken) {
        Claims claims = jwtUtil.validateTokenAndGetClaims(refreshToken);
        Long memberId = Long.parseLong(claims.getSubject());

        // Redis에서 토큰 가져와서 검증
        String storedRefreshToken = tokenService.getRefreshToken(memberId);
        if (!refreshToken.equals(storedRefreshToken)) {
            throw new IllegalArgumentException("유효하지 않은 리프레시 토큰입니다.");
        }

        return jwtUtil.generateAccessToken(memberId);
    }

    // 로그아웃
    public void logout(Member member, String accessToken) {
        System.out.println("[Service] 로그아웃 요청 - member: " + member);
        System.out.println("[Service] 전달된 AccessToken: " + accessToken);

        // 1. RefreshToken 삭제 (Redis에서)
        tokenService.deleteRefreshToken(member.getId());

        // 2. AccessToken 블랙리스트 등록 (남은 유효 시간에 맞춰 설정 가능)
        tokenService.blacklistAccessToken(accessToken, Duration.ofMinutes(15)); // 🔁 실제 만료 시간만큼 넣어도 좋음

        System.out.println("[Service] Redis에서 RefreshToken 제거 및 AccessToken 블랙리스트 처리 완료");
    }

    public Member validateMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("회원 정보를 찾을 수 없습니다."));
    }

    // 닉네임 또는 주소로 회원 검색
    public List<MemberResponseDto> searchMembers(String query, Member member) {
        return memberRepository
                .findByNicknameContainingIgnoreCaseOrAddressContainingIgnoreCase(query, query)
                .stream()
                .filter(m -> !m.getId().equals(member.getId())) // 본인 제외
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    // 닉네임 조회
    public boolean existsByNickname(String nickname) {
        return memberRepository.existsByNickname(nickname);
    }

    /**
     * 비밀번호 변경
     * @param member 로그인된 사용자 엔티티
     * @param currentPassword 현재 비밀번호(평문)
     * @param newPassword 새 비밀번호(평문)
     */
    public void changePassword(Member member, String currentPassword, String newPassword) {
        // 현재 비밀번호가 일치하는지 확인
        if (!passwordEncoder.matches(currentPassword, member.getPassword())) {
            throw new IllegalArgumentException("현재 비밀번호가 일치하지 않습니다.");
        }
        // 새 비밀번호로 암호화 후 저장
        member.setPassword(passwordEncoder.encode(newPassword));
        memberRepository.save(member);
    }
}
