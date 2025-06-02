package com.buddy.pium.dto.common;

import lombok.*;

import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberResponseDto {

    private Long id;
    private String username;
    private String nickname;
    private String address;
    private LocalDate birth;
    private String profileImage;
    private Long mateInfo; // Optional
}
