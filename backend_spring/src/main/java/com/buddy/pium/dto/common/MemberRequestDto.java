package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberRequestDto {

    private Long id;
    private String password;
    private String username;        // length: 50
    private String nickname;        // length: 50
    private String email;           // length: 100
    private String phoneNumber;     // length: 15
    private String address;         // length: 100
    private LocalDate birth;        //
    private Enum.Gender gender;          // 성병: 'F', 'M' 두가지로만 사용
    private String profileImage;    // 개인 사진 저장 경로
}
