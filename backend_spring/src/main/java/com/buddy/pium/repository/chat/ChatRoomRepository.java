package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    // DM
    @Query("""
    SELECT crm.chatRoom
    FROM ChatRoomMember crm
    WHERE crm.chatRoom.isGroup = false
      AND crm.member.id IN (:memberId1, :memberId2)
    GROUP BY crm.chatRoom
    HAVING COUNT(DISTINCT crm.member.id) = 2
""")
    Optional<ChatRoom> findDirectChatRoomBetween(Long memberId1, Long memberId2);

    // 나눔
    @Query("""
    SELECT crm.chatRoom
    FROM ChatRoomMember crm
    WHERE crm.chatRoom.sharePost.id = :postId
      AND crm.member.id IN (:memberId1, :memberId2)
    GROUP BY crm.chatRoom
    HAVING COUNT(DISTINCT crm.member.id) = 2
""")
    Optional<ChatRoom> findSharedChatRoomWithTwoMembers(Long postId, Long memberId1, Long memberId2);


}
