package com.buddy.pium.dto.common;

import lombok.*;
import com.buddy.pium.entity.common.Enum;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberResponseDto {
    private Long id;
    private String username;
    private String nickname;
    private String email;
    private String password;
    private String phoneNumber;
    private String address;
    private LocalDate birth;
    private Enum.Gender gender;
    private String profileImage;
    private Long mateInfo;
    private String refreshToken;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}