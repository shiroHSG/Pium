package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    @Query("""
    SELECT cr FROM ChatRoom cr
    JOIN cr.chatRoomMembers m1
    JOIN cr.chatRoomMembers m2
    WHERE cr.type = :type
      AND m1.member = :sender
      AND m2.member = :receiver
      AND (
          (:type = 'SHARE' AND cr.share.id = :shareId)
          OR (:type = 'DIRECT' AND cr.share IS NULL)
      )
""")
    Optional<ChatRoom> findExistingDirectRoom(
            @Param("sender") Member sender,
            @Param("receiver") Member receiver,
            @Param("type") Enum.ChatRoomType type,
            @Param("shareId") Long shareId
    );

    @Query("""
    SELECT cr FROM ChatRoom cr
    JOIN FETCH cr.chatRoomMembers crm
    WHERE crm.member.id = :memberId
""")
    List<ChatRoom> findAllByMemberIdWithMembers(@Param("memberId") Long memberId);

    Optional<ChatRoom> findByInviteCode(String inviteCode);
}
