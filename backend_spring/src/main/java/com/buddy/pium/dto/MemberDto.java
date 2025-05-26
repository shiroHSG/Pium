package com.buddy.pium.dto;

import lombok.*;
import java.time.LocalDate;
import java.sql.Timestamp;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberDto {

    private Long memberId;
    private String email;
    private String password;
    private String name;
    private String nickname;
    private String phone;
    private String address;
    private LocalDate birth;
    private String gender;
    private String profileImg;
    private String mateInfo;
    private Timestamp createAt;
    private Timestamp updatedAt;
}
