package com.buddy.pium.config;

import com.buddy.pium.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.hibernate.annotations.DialectOverride;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.EnableWebSocketMessageBroker;
import org.springframework.web.socket.config.annotation.StompEndpointRegistry;
import org.springframework.web.socket.config.annotation.WebSocketMessageBrokerConfigurer;

@Configuration
@EnableWebSocketMessageBroker
@RequiredArgsConstructor
public class WebSocketConfig implements WebSocketMessageBrokerConfigurer {

    private final JwtUtil jwtUtil;

    /**
     * webSocket 연결, Endpoint 설정
     * 클라이언트는 여기에 ws://localhost:8080/ws/chat 로 연결
     */
    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        registry.addEndpoint("/ws/chat")   //Flutter에서 사용할 WebSocket URL
                .addInterceptors(new JwtHandshakeInterceptor(jwtUtil)) // 여기에 등록!
                .setAllowedOriginPatterns("*")  //CORS(다른 서버에서 자원 접근) 허용
                .withSockJS();
    }

    /**
     * 라우팅 설정
     * 서버 -> 클라이언트 : /sub/~~
     * 클라이언트 -> 서버 : /pub/~~
     */
    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // 서버가 브로드캐스트할 경로 prefix
        registry.enableSimpleBroker("/sub");
        // 클라이언트가 서버로 전송할 때 붙이는 prefix
        registry.setApplicationDestinationPrefixes("/pub");
    }
}
