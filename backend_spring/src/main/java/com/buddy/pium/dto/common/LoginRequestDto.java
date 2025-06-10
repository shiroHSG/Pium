package com.buddy.pium.dto.common;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequestDto {
    private String email;
    private String password;
}
