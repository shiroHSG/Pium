package com.buddy.pium.repository.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoom, Long> {
    // DM
    Optional<ChatRoom> findDirectChatRoomBetween(Long senderId, Long receiverId);

    // 나눔
    Optional<ChatRoom> findShareChatRoomBetween(Long senderId, Long receiverId, Long postId);

    // 멤버 목록 조회
    List<ChatRoomMember> findByChatRoom(ChatRoom chatRoom);
}
