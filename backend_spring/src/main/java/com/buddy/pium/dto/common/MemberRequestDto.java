package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberRequestDto {
    @NotBlank(message = "이메일을 입력하세요")
    private String email;           // length: 100
    @NotBlank(message = "패스워드를 입력하세요")
    private String password;
    @NotBlank(message = "이름을 입력하세요")
    private String username;        // length: 50
    @NotBlank(message = "닉네임을 입력하세요")
    private String nickname;        // length: 50
//    @NotBlank(message = "전화번호를 입력하세요")
    private String phoneNumber;     // length: 15
//    @NotBlank(message = "주소를 입력하세요")
    private String address;         // length: 100
//    @NotNull(message = "생일을 입력하세요")
    private LocalDate birth;        //
//    @NotBlank(message = "성별을 선택하세요")
    private Enum.Gender gender;          // 성별: 'F', 'M' 두가지로만 사용
    private String profileImageUrl;    // 개인 사진 저장 경로
}
