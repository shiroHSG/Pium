package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomMemberResponseDTO;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
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

    // 채팅방 멤버 조회
    @Transactional
    public List<ChatRoomMemberResponseDTO> getChatRoomMembers(Long chatRoomId, Long currentMemberId) {
        // 채팅방 존재 확인
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방이 존재하지 않습니다."));

        // 참여자 여부 확인
        boolean isMember = chatRoomMemberRepository.existsByChatRoomIdAndMemberId(chatRoomId, currentMemberId);
        if (!isMember) {
            throw new AccessDeniedException("해당 채팅방에 참여하고 있지 않습니다.");
        }

        // 채팅방 멤버 조회
        List<ChatRoomMember> members = chatRoomMemberRepository.findByChatRoomId(chatRoomId);

        // DTO 변환
        return members.stream()
                .map(m -> new ChatRoomMemberResponseDTO(
                        m.getMember().getId(),
                        m.getMember().getNickname(),
                        m.getMember().getProfileImageUrl(),
                        m.isAdmin()
                ))
                .collect(Collectors.toList());
    }

    // 관리자 위임
    @Transactional
    public void delegateAdmin(Long chatRoomId, Long currentAdminId, Long newAdminId) {
        // 채팅방 존재 여부 확인
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new EntityNotFoundException("채팅방이 존재하지 않습니다."));

        // 현재 요청자가 채팅방 멤버인지 확인
        ChatRoomMember currentAdmin = chatRoomMemberRepository
                .findByChatRoomIdAndMemberId(chatRoomId, currentAdminId)
                .orElseThrow(() -> new IllegalArgumentException("당신은 이 채팅방의 멤버가 아닙니다."));

        if (!currentAdmin.isAdmin()) {
            throw new AccessDeniedException("당신은 관리자가 아닙니다.");
        }

        if (currentAdminId.equals(newAdminId)) {
            throw new IllegalArgumentException("자기 자신에게는 관리자 권한을 위임할 수 없습니다.");
        }

        // 위임 대상이 해당 채팅방의 멤버인지 확인
        ChatRoomMember newAdmin = chatRoomMemberRepository
                .findByChatRoomIdAndMemberId(chatRoomId, newAdminId)
                .orElseThrow(() -> new IllegalArgumentException("위임 대상이 채팅방의 멤버가 아닙니다."));

        // 위임 실행
        currentAdmin.setAdmin(false);
        newAdmin.setAdmin(true);
    }
}
