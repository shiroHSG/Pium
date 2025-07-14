package com.buddy.pium.service.common;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;

@Service
@RequiredArgsConstructor
public class TokenService {

    private final RedisTemplate<String, String> redisTemplate;

    // 🔐 Refresh Token 저장
    public void saveRefreshToken(Long memberId, String refreshToken, Duration ttl) {
        redisTemplate.opsForValue().set("refresh:" + memberId, refreshToken, ttl);
    }

    // 🔍 Refresh Token 조회
    public String getRefreshToken(Long memberId) {
        return redisTemplate.opsForValue().get("refresh:" + memberId);
    }

    // 🧹 Refresh Token 삭제 (ex. 로그아웃)
    public void deleteRefreshToken(Long memberId) {
        redisTemplate.delete("refresh:" + memberId);
    }

    // ⛔ Access Token 블랙리스트 등록
    public void blacklistAccessToken(String accessToken, Duration ttl) {
        redisTemplate.opsForValue().set("blacklist:" + accessToken, "true", ttl);
    }

    // ✅ 블랙리스트 여부 확인
    public boolean isAccessTokenBlacklisted(String accessToken) {
        return Boolean.TRUE.equals(redisTemplate.hasKey("blacklist:" + accessToken));
    }
}
