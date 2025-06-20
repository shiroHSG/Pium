package com.buddy.pium.resolver;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.core.MethodParameter;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Component;
import org.springframework.web.bind.support.WebDataBinderFactory;
import org.springframework.web.context.request.NativeWebRequest;
import org.springframework.web.method.support.HandlerMethodArgumentResolver;
import org.springframework.web.method.support.ModelAndViewContainer;

@Component
@RequiredArgsConstructor
public class CurrentMemberArgumentResolver implements HandlerMethodArgumentResolver {

    private final MemberRepository memberRepository;

    @Override
    public boolean supportsParameter(MethodParameter parameter) {
        return parameter.hasParameterAnnotation(CurrentMemberId.class)
                || parameter.hasParameterAnnotation(CurrentMember.class);
    }

    @Override
    public Object resolveArgument(MethodParameter parameter,
                                  ModelAndViewContainer mavContainer,
                                  NativeWebRequest webRequest,
                                  WebDataBinderFactory binderFactory) {

        Authentication auth = (Authentication) webRequest.getUserPrincipal();

        if (auth == null || auth.getPrincipal() == null) {
            throw new IllegalStateException("인증 정보가 존재하지 않습니다.");
        }

        Long memberId;
        try {
            memberId = (Long) auth.getPrincipal();
        } catch (ClassCastException e) {
            throw new IllegalStateException("인증 사용자 형식이 잘못되었습니다.");
        }

        if (parameter.hasParameterAnnotation(CurrentMemberId.class)) {
            return memberId;
        }

        if (parameter.hasParameterAnnotation(CurrentMember.class)) {
            return memberRepository.findById(memberId)
                    .orElseThrow(() -> new IllegalStateException("회원을 찾을 수 없습니다."));
        }

        return null;
    }
}
