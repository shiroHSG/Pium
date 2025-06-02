package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface ChatRoomMemberRepository extends JpaRepository<ChatRoomMember, Long> {
    List<ChatRoomMember> findByChatRoomId(Long chatRoomId);

    List<ChatRoomMember> findByChatRoom(ChatRoom chatRoom);

    @Query("""
    SELECT crm.lastReadMessageId
    FROM ChatRoomMember crm
    WHERE crm.chatRoom.id = :chatRoomId
      AND crm.member.id = :memberId
""")
    Long findLastReadMessageId(Long chatRoomId, Long memberId);

    List<ChatRoomMember> findByMemberId(Long memberId);
}
