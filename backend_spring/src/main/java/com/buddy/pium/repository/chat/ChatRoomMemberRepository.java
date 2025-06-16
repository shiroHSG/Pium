package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

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

    Optional<ChatRoomMember> findByChatRoomAndMember(ChatRoom chatRoom, Member member);

    boolean existsByChatRoomIdAndMemberId(Long chatRoomId, Long memberId);

    @Query("""
    SELECT COUNT(crm)
    FROM ChatRoomMember crm
    WHERE crm.chatRoom.id = :chatRoomId
      AND crm.member.id <> :currentMemberId
      AND (crm.lastReadMessageId IS NULL OR crm.lastReadMessageId < :messageId)
""")
    int countUnreadMembers(@Param("chatRoomId") Long chatRoomId,
                           @Param("messageId") Long messageId,
                           @Param("currentMemberId") Long currentMemberId);


    Optional<ChatRoomMember> findByChatRoomAndMemberId(ChatRoom chatRoom, Long memberId);

    int countByChatRoom(ChatRoom chatRoom);

    Optional<Object> findByChatRoomIdAndMember(Long chatRoomId, Member member);

    boolean existsByChatRoomAndMember(ChatRoom chatRoom, Member member);
}
