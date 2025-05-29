package com.buddy.pium.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys; // ✅ 추가: Key 생성을 위한 클래스
import org.springframework.stereotype.Component;

import java.security.Key; // ✅ 추가: Key 타입
import java.util.Date;

@Component
public class JwtUtil {

    // ✅ 수정: 단순 문자열 대신 32자 이상 길이의 시크릿 키 사용 (서명용 Key 객체 필요)
    private static final String SECRET = "ThisIsMySuperSecretJwtKeyThatIsLongEnough123456";

    // ✅ 추가: 문자열 키를 byte 배열로 변환해 Key 객체로 생성
    private static final Key KEY = Keys.hmacShaKeyFor(SECRET.getBytes());

    private static final long EXPIRATION_TIME = 1000 * 60 * 60; // 1시간

    // ✅ 수정: claim에 email 포함, Key 객체를 사용한 signWith 방식으로 변경
    public String generateToken(Long id, String email) {
        return Jwts.builder()
                .setSubject(String.valueOf(id)) // JWT의 subject로 사용자 ID 설정
                .claim("email", email)         // 이메일 클레임에 추가
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + EXPIRATION_TIME))
                .signWith(KEY, SignatureAlgorithm.HS256) // ✅ 수정된 서명 방식
                .compact();
    }

    // ✅ 수정: parserBuilder()를 통해 Key 객체로 파싱 (0.11.x 이상에서 필수)
    public Claims validateTokenAndGetClaims(String token) {
        try {
            return Jwts.parserBuilder()
                    .setSigningKey(KEY) // ✅ Key 객체 사용
                    .build()
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            throw new RuntimeException("Token expired");
        } catch (JwtException e) {
            throw new RuntimeException("Invalid token");
        }
    }

    // 사용자 ID 추출
    public Long getUserId(String token) {
        return Long.parseLong(validateTokenAndGetClaims(token).getSubject());
    }

    // ✅ 선택: 이메일 클레임 추출 메서드 추가
    public String getEmail(String token) {
        return validateTokenAndGetClaims(token).get("email", String.class);
    }
}
