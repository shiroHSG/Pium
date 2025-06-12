package com.buddy.pium.service.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomBan;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.chat.ChatRoomBanRepository;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChatRoomBanService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final ChatRoomBanRepository chatRoomBanRepository;

    @Transactional
    public void banMember(Long chatRoomId, Member member, Long targetMemberId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방이 존재하지 않습니다"));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new IllegalArgumentException("밴 기능은 그룹 채팅방에서만 사용할 수 있습니다");
        }

        ChatRoomMember requester = chatRoomMemberRepository.findByChatRoomIdAndMemberId(chatRoomId, member.getId())
                .orElseThrow(() -> new IllegalArgumentException("요청자가 채팅방에 참여하고 있지 않습니다"));

        if (!requester.isAdmin()) {
            throw new IllegalArgumentException("관리자만 밴을 수행할 수 있습니다");
        }

        ChatRoomMember target = chatRoomMemberRepository.findByChatRoomIdAndMemberId(chatRoomId, targetMemberId)
                .orElseThrow(() -> new IllegalArgumentException("대상 사용자가 채팅방에 참여하고 있지 않습니다"));

        // 이미 밴되어 있는지 확인
        boolean alreadyBanned = chatRoomBanRepository.existsByChatRoomIdAndBannedMemberId(chatRoomId, targetMemberId);
        if (alreadyBanned) {
            throw new IllegalArgumentException("이미 밴된 사용자입니다");
        }

        // 1. ChatRoomMember에서 삭제
        chatRoomMemberRepository.delete(target);

        // 2. ChatRoomBan에 등록
        Member bannedMember = target.getMember();
        ChatRoomBan ban = ChatRoomBan.builder()
                .chatRoom(chatRoom)
                .bannedMember(bannedMember)
                .build();
        chatRoomBanRepository.save(ban);
    }

}
