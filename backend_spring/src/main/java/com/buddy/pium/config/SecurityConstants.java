package com.buddy.pium.config;

import java.util.List;

public class SecurityConstants {

    public static final List<String> ALLOWED_URLS = List.of(
            "/api/member/login",         // 토큰 생성을 위해 인증 없이 사용
            "/api/member/register",      // 사용자 토큰 생성을 하기 위해선 사용자 생성이 우선
            "/api/member/users/**",               // 개발자가 전체 Member테이블 조회 시 사용
            "/api/member/reissue",        // RefreshToken으로 AccessToken 재발급 (비인증 경로 필요)
            "/api/member/delete/**",
            "/api/shares/**",
            "/api/policies/**",
            "/uploads/**"
    );
}
