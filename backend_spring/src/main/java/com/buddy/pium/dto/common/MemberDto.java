package com.buddy.pium.dto.common;

import com.buddy.pium.entity.common.Enum.Gender;
import lombok.*;

        import java.sql.Timestamp;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MemberDto {
    private Long id;
    private String username;
    private String nickname;
    private String email;
    private String phoneNumber;
    private String address;
    private LocalDate birth;
    private Gender gender;
    private String profileImage;
    private String mateInfo;
    private Timestamp createdAt;
    private Timestamp updatedAt;
}