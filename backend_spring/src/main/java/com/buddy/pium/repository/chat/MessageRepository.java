package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.Message;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;


public interface MessageRepository extends JpaRepository<Message, Long> {

    int countByChatRoomAndIdGreaterThanAndSenderNot(ChatRoom chatRoom, Long id, Member sender);

    int countByChatRoomAndSenderNot(ChatRoom chatRoom, Member sender);

    List<Message> findTop100ByChatRoomIdOrderByIdDesc(Long chatRoomId);

    List<Message> findByChatRoomIdAndIdGreaterThanOrderByIdAsc(Long chatRoomId, Long lastReadMessageId);

    List<Message> findTop100ByChatRoomIdAndIdLessThanOrderByIdDesc(Long chatRoomId, Long pivotId);

    List<Message> findTop100ByChatRoomIdAndIdGreaterThanOrderByIdAsc(Long chatRoomId, Long pivotId);
}
