package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.Message;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;


public interface MessageRepository extends JpaRepository<Message, Long> {
    int countByChatRoomAndSentAtAfterAndSenderNot(ChatRoom chatRoom, LocalDateTime joinedAt, Member currentUser);

    int countByChatRoomAndIdGreaterThanAndSentAtAfterAndSenderNot(ChatRoom chatRoom, Long lastReadMessageId, LocalDateTime joinedAt, Member currentUser);

    // 처음 입장 시
    List<Message> findByChatRoomIdAndSentAtAfterOrderByIdAsc(Long chatRoomId, LocalDateTime joinedAt);

    // 최신 이후 메시지
    List<Message> findByChatRoomIdAndIdGreaterThanEqualAndSentAtAfterOrderByIdAsc(Long chatRoomId, Long lastReadMessageId, LocalDateTime joinedAt);

    // 이전 10개
    List<Message> findTop10ByChatRoomIdAndIdLessThanAndSentAtAfterOrderByIdDesc(Long chatRoomId, Long lastReadMessageId, LocalDateTime joinedAt);

    // prev 무한스크롤
    List<Message> findTop100ByChatRoomIdAndIdLessThanAndSentAtAfterOrderByIdDesc(Long chatRoomId, Long pivotId, LocalDateTime joinedAt);


    @Query("""
    SELECT COUNT(m)
    FROM Message m
    WHERE m.chatRoom.id = :chatRoomId
      AND m.id > (
          SELECT COALESCE(crm.lastReadMessageId, 0)
          FROM ChatRoomMember crm
          WHERE crm.chatRoom.id = :chatRoomId
            AND crm.member.id = :memberId
      )
""")
    int countUnreadMessagesForMember(@Param("chatRoomId") Long chatRoomId,
                                     @Param("memberId") Long memberId);
}
