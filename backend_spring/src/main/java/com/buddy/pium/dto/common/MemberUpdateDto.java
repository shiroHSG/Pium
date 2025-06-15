package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum;
import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberUpdateDto {
    private String password;
    private String username;
    private String nickname;
    private String phoneNumber;
    private String address;
    private LocalDate birth;
    private Enum.Gender gender;
    private String profileImageUrl;
}
