package com.buddy.pium.config;

import java.util.List;

public class SecurityConstants {

    public static final List<String> ALLOWED_URLS = List.of(
            "/api/member/login",
            "/api/member/register",
            "/api/member/checkNickName",
            "/api/member/users/**",
            "/api/member/reissue",    // RefreshToken 발급시 AccessToken 재발급 (비회원 인증 필요)
            "/api/member/delete/**",
            "/api/policies/**",
            "/uploads/**",
            "/ws/**"
                    // "/api/shares/**", 인증이 필요한 경로이므로 포함하면 안됨

    );
}