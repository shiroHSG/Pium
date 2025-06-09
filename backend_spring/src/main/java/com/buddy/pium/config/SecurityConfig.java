package com.buddy.pium.config;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.Customizer;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import com.buddy.pium.config.JwtFilter; // ✅ JwtFilter import
import org.springframework.security.config.http.SessionCreationPolicy; // ✅ 세션 정책 import
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter; // ✅ 필터 등록용 import
// 비밀번호 암호화
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.util.List;
@Configuration
@EnableMethodSecurity
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtFilter jwtFilter; // ✅ JwtFilter 주입

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .cors(Customizer.withDefaults())
                .csrf(csrf -> csrf.disable())
                // ✅ 세션을 사용하지 않는 JWT 기반 인증 방식으로 설정
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                .authorizeHttpRequests(auth -> auth
                        // ✅ 로그인 및 회원가입 요청은 허용, 비인가 요청시 엔드포인트 추가
                        .requestMatchers("/api/member/login", "/api/member/add", "/api/member").permitAll()
                        .requestMatchers("/api/shares/**").authenticated() // Share API 추가😃
                        // ✅ 그 외의 요청은 인증 필요
                        .anyRequest().authenticated()
                )
                // ✅ JWT 필터를 UsernamePasswordAuthenticationFilter 앞에 추가
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);
        return http.build();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOrigins(List.of("http://localhost:3000"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }

    // BCrypt passwordEncorder 적용
    @Bean
    public BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

}