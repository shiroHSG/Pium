package com.buddy.pium.config;

import java.util.List;

public class SecurityConstants {

    public static final List<String> ALLOWED_URLS = List.of(
            "/api/member/login",
            "/api/member/register",
            "/api/member/users/**",
            "/api/member/reissue",    // RefreshToken 발급시 AccessToken 재발급 (비회원 인증 필요)
            "/api/member/delete/**",
            // 나머지 허용 경로를 팀 규칙에 맞게 정리!
            "/api/policies/**",
            "/api/shares/**",
            "/uploads/**",
            "/ws/**"
    );
}