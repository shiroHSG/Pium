package com.buddy.pium.config;

import com.buddy.pium.util.JwtUtil;
import io.jsonwebtoken.Claims;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.Collections;

import static com.buddy.pium.config.SecurityConstants.ALLOWED_URLS;

@Component
public class JwtFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    public JwtFilter(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain) throws ServletException, IOException {

        String uri = request.getRequestURI();
        System.out.println("[JwtFilter] 요청 URI: " + uri);

        // ✅ 인증 제외 URL 처리
        if (ALLOWED_URLS.contains(uri)) {
            System.out.println("[JwtFilter] 인증 제외 경로 → 필터 통과");
            filterChain.doFilter(request, response);
            return;
        }

        String header = request.getHeader("Authorization");
        System.out.println("[JwtFilter] Authorization 헤더: " + header);

        if (header != null && header.startsWith("Bearer ")) {
            String token = header.substring(7);
            try {
                Claims claims = jwtUtil.validateTokenAndGetClaims(token);
                Long userId = Long.parseLong(claims.getSubject());

                // ✅ mateInfo 추출 (nullable)
                Object mateInfoRaw = claims.get("mateInfo");
                Long mateInfo = (mateInfoRaw != null) ? Long.parseLong(mateInfoRaw.toString()) : null;

                // ✅ Authentication 구성
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(userId, null, Collections.emptyList());

                authentication.setDetails(mateInfo); // mateInfo를 details에 저장
                SecurityContextHolder.getContext().setAuthentication(authentication);

                System.out.println("[JwtFilter] 토큰 유효 → SecurityContext 등록 (memberId=" + userId + ", mateInfo=" + mateInfo + ")");

            } catch (RuntimeException e) {
                System.out.println("[JwtFilter] 토큰 검증 실패 → 예외: " + e.getMessage());
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.setContentType("application/json");
                response.setCharacterEncoding("UTF-8");
                response.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"" + e.getMessage() + "\"}");
                return;
            }
        } else {
            System.out.println("[JwtFilter] 토큰 없음 또는 잘못된 형식 → 401 응답");
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            response.getWriter().write("{\"error\": \"Unauthorized\", \"message\": \"Missing or invalid token\"}");
            return;
        }

        filterChain.doFilter(request, response);
    }
}
