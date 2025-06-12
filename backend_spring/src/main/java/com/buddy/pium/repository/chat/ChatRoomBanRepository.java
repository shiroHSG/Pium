package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomBan;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ChatRoomBanRepository extends JpaRepository<ChatRoomBan, Long> {
    boolean existsByChatRoomIdAndBannedMemberId(Long chatRoomId, Long targetMemberId);

    boolean existsByChatRoomAndBannedMember(ChatRoom chatRoom, Member member);
}
