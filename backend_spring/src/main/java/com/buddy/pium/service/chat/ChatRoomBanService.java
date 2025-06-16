package com.buddy.pium.service.chat;

import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomBan;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.InvalidChatRoomOperationException;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.chat.ChatRoomBanRepository;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.service.common.MemberService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChatRoomBanService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final ChatRoomBanRepository chatRoomBanRepository;

    private final ChatRoomMemberService chatRoomMemberService;
    private final MemberService memberService;

    @Transactional
    public void banMember(Long chatRoomId, Member member, Long targetMemberId) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방을 찾을 수 없습니다."));

        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new InvalidChatRoomOperationException("그룹 채팅방이 아닙니다.");
        }

        ChatRoomMember admin = chatRoomMemberService.validateAdmin(chatRoom, member);
        Member target = memberService.validateMember(targetMemberId);
        ChatRoomMember targetMember = chatRoomMemberService.validateChatRoomMember(chatRoom, target);

        isBannedMember(chatRoom, target);
        chatRoomMemberRepository.delete(targetMember);

        ChatRoomBan ban = ChatRoomBan.builder()
                .chatRoom(chatRoom)
                .bannedMember(target)
                .build();
        chatRoomBanRepository.save(ban);
    }

    public void isBannedMember(ChatRoom chatRoom, Member member) {
        if (chatRoomBanRepository.existsByChatRoomAndBannedMember(chatRoom, member)) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }
    }
}
