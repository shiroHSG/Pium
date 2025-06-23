package com.buddy.pium.dto.chat;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class InviteCheckResponseDto {
    private String chatRoomName;
    // 가입여부 true= 채팅방으로, alreadyJoined,requirePassword 둘다 false일때 비밀번호 입력 모달창 뜨게
    // requirePassword이 true여도 alreadyJoined이 true면 바로 채팅방으로 이동
    private boolean alreadyJoined;
    private boolean requirePassword; //비밀번호 있으면 true,
}