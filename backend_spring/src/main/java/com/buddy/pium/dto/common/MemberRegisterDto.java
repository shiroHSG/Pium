package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberRegisterDto {

    private String username;
    private String nickname;
    private String email;
    private String password;        // 회원가입 필수
    private String phoneNumber;
    private String address;
    private LocalDate birth;
    private Enum.Gender gender;
    private String profileImageUrl;
}
