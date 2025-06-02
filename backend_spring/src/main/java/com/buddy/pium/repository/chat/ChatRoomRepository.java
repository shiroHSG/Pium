package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
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
          AND m1.member.id = :senderId
          AND m2.member.id = :receiverId
          AND (
              (:type = 'SHARE' AND cr.sharePost.id = :sharePostId)
              OR (:type = 'DIRECT' AND cr.sharePost IS NULL)
          )
    """)
    Optional<ChatRoom> findExistingDirectRoom(
            @Param("senderId") Long senderId,
            @Param("receiverId") Long receiverId,
            @Param("type") Enum.ChatRoomType type,
            @Param("sharePostId") Long sharePostId
    );
}
