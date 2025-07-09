package com.buddy.pium.dto.common;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 비밀번호 변경 요청 DTO
 * - currentPassword: 현재 비밀번호
 * - newPassword: 새 비밀번호
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
public class ChangePasswordRequestDto {
    private String currentPassword;
    private String newPassword;
}
