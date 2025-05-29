package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.Message;
import jakarta.transaction.Transactional;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface MessageRepository extends JpaRepository<Message, Long> {

    @Query("""
    SELECT COUNT(m)
    FROM Message m
    WHERE m.chatRoom.id = :chatRoomId
      AND m.id > :lastReadMessageId
      AND m.sender.id <> :memberId
""")
    int countUnreadMessages(Long chatRoomId, Long memberId, Long lastReadMessageId);



    @Query("SELECT m FROM Message m WHERE m.chatRoom.id = :chatRoomId ORDER BY m.sentAt DESC LIMIT 1")
    Message findLastMessage(@Param("chatRoomId") Long chatRoomId);

    // 읽음 처리 → 메시지 ID 이하의 메시지를 모두 읽음 처리
    @Modifying
    @Transactional
    @Query("""
    UPDATE Message m
    SET m.isRead = true
    WHERE m.chatRoom.id = :chatRoomId
      AND m.id <= :lastReadMessageId
      AND m.sender.id <> :memberId
""")
    void markAsReadUpTo(@Param("chatRoomId") Long chatRoomId,
                        @Param("memberId") Long memberId,
                        @Param("lastReadMessageId") Long lastReadMessageId);

    @Query("""
    SELECT COUNT(m)
    FROM Message m
    WHERE m.chatRoom.id = :chatRoomId
      AND m.sender.id <> :memberId
""")
    int countAllUnreadMessagesExceptSender(Long chatRoomId, Long memberId);

}
