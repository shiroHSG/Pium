package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomMemberResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.BusinessException;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.service.common.MemberService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatRoomMemberService {

    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final MemberService memberService;

    // 채팅방 멤버 조회 (chatRoom을 인자로 받도록 수정)
    @Transactional
    public List<ChatRoomMemberResponseDTO> getChatRoomMembers(ChatRoom chatRoom, Member member) {
        if (!isMember(chatRoom, member)) {
            throw new AccessDeniedException("해당 채팅방에 참여하고 있지 않습니다.");
        }

        List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoom(chatRoom);

        return members.stream()
                .map(ChatRoomMemberResponseDTO::from)
                .collect(Collectors.toList());
    }

    // 관리자 위임 (chatRoom을 인자로 받도록 수정)
    @Transactional
    public void delegateAdmin(ChatRoom chatRoom, Member member, Long newAdminId) {
        ChatRoomMember admin = validateAdmin(chatRoom, member);
        Member newAdminMember = memberService.validateMember(newAdminId);

        if (member.equals(newAdminMember)) {
            throw new BusinessException("자기 자신에게는 관리자 권한을 위임할 수 없습니다.");
        }

        ChatRoomMember newAdmin = validateChatRoomMember(chatRoom, newAdminMember);

        admin.setAdmin(false);
        newAdmin.setAdmin(true);
    }

    public boolean isMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
    }

    public ChatRoomMember validateChatRoomMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방 멤버가 아닙니다."));
    }

    public ChatRoomMember validateAdmin(ChatRoom chatRoom, Member member) {
        ChatRoomMember chatRoomMember = validateChatRoomMember(chatRoom, member);
        if (!chatRoomMember.isAdmin()) {
            throw new AccessDeniedException("당신은 관리자가 아닙니다.");
        }
        return chatRoomMember;
    }

    public ChatRoomMember createChatRoomMember(ChatRoom chatRoom, Member member, boolean isAdmin) {
        return ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(member)
                .isAdmin(isAdmin)
                .build();
    }

}
