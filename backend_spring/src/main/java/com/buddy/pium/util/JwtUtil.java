package com.buddy.pium.util;

import io.jsonwebtoken.*;
import io.jsonwebtoken.io.Decoders;
import io.jsonwebtoken.security.Keys;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;

import javax.crypto.SecretKey;
import java.nio.charset.StandardCharsets;
import java.util.Date;

@Component
public class JwtUtil {

    @Value("${jwt.secret}")
    private String secretKey;

    // Access Token 유효기간: 1시간
    private final long ACCESS_EXPIRATION = 60 * 60 * 1000;

    // Access Token 유효기간: 1분 Test
    // private final long ACCESS_EXPIRATION = 60 * 1000;

    // Refresh Token 유효기간: 7일
    private final long REFRESH_EXPIRATION = 7 * 24 * 60 * 60 * 1000;

    
    /**
     * 서명용 SecretKey 생성 (Base64 디코딩 후 키로 사용)
     */
    private SecretKey getSigningKey() {
        byte[] keyBytes = Decoders.BASE64.decode(secretKey);
        return Keys.hmacShaKeyFor(secretKey.getBytes(StandardCharsets.UTF_8));
    }

    /**
     * Access Token 발급 (id, mateInfo 포함)
     */
    public String generateAccessToken(Long memberId) {
        JwtBuilder builder = Jwts.builder()
                .setSubject(memberId.toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + ACCESS_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256);

        return builder.compact();
    }

    /**
     * Refresh Token 발급 (id만 포함)
     */
    public String generateRefreshToken(Long memberId) {
        return Jwts.builder()
                .setSubject(memberId.toString())
                .setIssuedAt(new Date())
                .setExpiration(new Date(System.currentTimeMillis() + REFRESH_EXPIRATION))
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    /**
     * 토큰 유효성 검사 및 Claim 추출
     */
    public Claims validateTokenAndGetClaims(String token) {
        try {
            return Jwts.parser()
                    .setSigningKey(getSigningKey())
                    .parseClaimsJws(token)
                    .getBody();
        } catch (ExpiredJwtException e) {
            throw new RuntimeException("토큰이 만료되었습니다.");
        } catch (JwtException e) {
            throw new RuntimeException("유효하지 않은 토큰입니다.");
        }
    }

    public boolean validateToken(String token) {
        try {
            Jwts.parser()
                    .setSigningKey(getSigningKey())
                    .parseClaimsJws(token);
            return true;
        } catch (JwtException | IllegalArgumentException e) {
            return false;
        }
    }

    /**
     * 토큰에서 memberId(Long) 추출
     */
    public Long getMemberIdFromToken(String token) {
        return Long.parseLong(validateTokenAndGetClaims(token).getSubject());
    }

    /**
     * 토큰에서 mateInfo(Long) 추출
     */
    public Long getMateInfoFromToken(String token) {
        Claims claims = validateTokenAndGetClaims(token);
        Object mateInfo = claims.get("mateInfo");
        return (mateInfo != null) ? Long.parseLong(mateInfo.toString()) : null;
    }

    // ✅ Authentication에서 mateInfo 추출
    public Long extractMateId(Authentication authentication) {
        Object details = authentication.getDetails();
        if (details instanceof Long) {
            return (Long) details;
        } else if (details instanceof String str) {
            try {
                return Long.parseLong(str);
            } catch (NumberFormatException e) {
                return null;
            }
        }
        return null;
    }
}
