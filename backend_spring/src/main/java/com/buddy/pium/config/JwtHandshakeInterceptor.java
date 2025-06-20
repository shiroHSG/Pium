package com.buddy.pium.config;

import com.buddy.pium.util.JwtUtil;
import org.springframework.http.HttpStatus;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Map;

public class JwtHandshakeInterceptor implements HandshakeInterceptor {

    private final JwtUtil jwtUtil;

    public JwtHandshakeInterceptor(JwtUtil jwtUtil) {
        this.jwtUtil = jwtUtil;
    }

    @Override
    public boolean beforeHandshake(ServerHttpRequest request,
                                   ServerHttpResponse response,
                                   WebSocketHandler wsHandler,
                                   Map<String, Object> attributes) throws Exception {
        try {
            System.out.println("📡 [beforeHandshake] 요청 URI: " + request.getURI());

            String token = UriComponentsBuilder.fromUriString(request.getURI().toString())
                    .build()
                    .getQueryParams()
                    .getFirst("token");

            System.out.println("🔐 [beforeHandshake] token: " + token);

            if (token == null || !jwtUtil.validateToken(token)) {
                System.out.println("⛔ [beforeHandshake] 유효하지 않은 토큰");
                response.setStatusCode(HttpStatus.UNAUTHORIZED); // 401
                return false;
            }

            Long userId = jwtUtil.getMemberIdFromToken(token);
            attributes.put("memberId", userId);
            System.out.println("✅ [beforeHandshake] 연결 허용 - memberId: " + userId);
            return true;

        } catch (Exception e) {
            System.out.println("🔥 [beforeHandshake] 예외 발생: " + e.getMessage());
            response.setStatusCode(HttpStatus.UNAUTHORIZED);
            return false;
        }
    }

    @Override
    public void afterHandshake(ServerHttpRequest request,
                               ServerHttpResponse response,
                               WebSocketHandler wsHandler,
                               Exception exception) {
        // 생략 가능
    }
}
