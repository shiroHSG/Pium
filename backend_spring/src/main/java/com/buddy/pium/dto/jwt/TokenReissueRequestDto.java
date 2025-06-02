package com.buddy.pium.dto.jwt;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class TokenReissueRequestDto {
    private String refreshToken;
}
