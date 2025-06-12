package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomMemberResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatRoomMemberService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;

    private final ChatRoomService chatRoomService;

    // 채팅방 멤버 조회
    @Transactional
    public List<ChatRoomMemberResponseDTO> getChatRoomMembers(Long chatRoomId, Member member) {
        // 채팅방 존재 확인
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);

        // 참여자 여부 확인
        if (!isMember(chatRoom,member)) {
            throw new AccessDeniedException("해당 채팅방에 참여하고 있지 않습니다.");
        }

        // 채팅방 멤버 조회
        List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoom(chatRoom);

        // DTO 변환
        return members.stream()
                .map(ChatRoomMemberResponseDTO::from)
                .collect(Collectors.toList());
    }

    // 관리자 위임
    @Transactional
    public void delegateAdmin(Long chatRoomId, Member member, Long newAdminId) {
        ChatRoom chatRoom = chatRoomService.validateChatRoom(chatRoomId);
        ChatRoomMember admin = validateChatRoomMember(chatRoom, member);

        validateAdminAuth(admin);

        if (currentAdmin.equals(newAdminMember)) {
            throw new IllegalArgumentException("자기 자신에게는 관리자 권한을 위임할 수 없습니다.");
        }

        // 위임 대상이 해당 채팅방의 멤버인지 확인
        ChatRoomMember newAdmin = chatRoomMemberRepository
                .findByChatRoomAndMember(chatRoom, newAdminMember)
                .orElseThrow(() -> new IllegalArgumentException("위임 대상이 채팅방의 멤버가 아닙니다."));

        // 위임 실행
        currentAdmin.setAdmin(false);
        newAdmin.setAdmin(true);
    }

    public boolean isMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
    }

    public ChatRoomMember validateChatRoomMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방 멤버가 아닙니다."));
    }

    public void validateAdminAuth(ChatRoomMember admin) {
        if (!admin.isAdmin()) {
            throw new AccessDeniedException("당신은 관리자가 아닙니다.");
        }
    }
}
