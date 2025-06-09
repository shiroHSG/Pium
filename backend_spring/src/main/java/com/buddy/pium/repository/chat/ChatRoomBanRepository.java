package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoomBan;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatRoomBanRepository extends JpaRepository<ChatRoomBan, Long> {
    boolean existsByChatRoomIdAndBannedMemberId(Long chatRoomId, Long targetMemberId);
}
