package com.buddy.pium.service.chat;

import com.buddy.pium.dto.chat.ChatRoomRequestDto;
import com.buddy.pium.dto.chat.ChatRoomResponseDto;
import com.buddy.pium.dto.chat.InviteCheckResponseDto;
import com.buddy.pium.dto.chat.InviteLinkResponseDto;
import com.buddy.pium.entity.chat.ChatRoom;
import com.buddy.pium.entity.chat.ChatRoomMember;
import com.buddy.pium.entity.chat.Enum;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.exception.BusinessException;
import com.buddy.pium.exception.InvalidChatRoomOperationException;
import com.buddy.pium.exception.InvalidPasswordException;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.chat.ChatRoomBanRepository;
import com.buddy.pium.repository.chat.ChatRoomMemberRepository;
import com.buddy.pium.repository.chat.ChatRoomRepository;
import com.buddy.pium.repository.chat.MessageRepository;
import com.buddy.pium.repository.share.ShareRepository;
import com.buddy.pium.service.FileUploadService;
import com.buddy.pium.service.common.MemberService;
import jakarta.persistence.EntityNotFoundException;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.apache.commons.lang3.RandomStringUtils;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatRoomService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatRoomMemberRepository chatRoomMemberRepository;
    private final ShareRepository shareRepository;
    private final MessageRepository messageRepository;
    private final FileUploadService fileUploadService;
    private final MemberService memberService;
    private final ChatRoomBanRepository chatRoomBanRepository;

    public ChatRoomResponseDto getOrCreateChatRoom(ChatRoomRequestDto dto, MultipartFile image, Member member) {
        Enum.ChatRoomType type = dto.getType();

        return switch (type) {
            case DIRECT, SHARE -> handleDirectOrShareChatRoom(dto, member);
            case GROUP -> handleGroupChatRoom(dto, image, member);
        };
    }

    private ChatRoomResponseDto handleDirectOrShareChatRoom(ChatRoomRequestDto dto, Member sender) {
        Enum.ChatRoomType type = dto.getType();
        Long shareId = dto.getShareId();

        Member receiver = memberService.validateMember(dto.getReceiverId());

        if (sender.equals(receiver)) {
            throw new BusinessException("자기 자신과는 채팅할 수 없습니다.");
        }

        Share share = validateSharePost(type, shareId);

        Optional<ChatRoom> optionalRoom =
                chatRoomRepository.findExistingDirectRoom(sender, receiver, type, shareId);
        if (optionalRoom.isPresent()) {
            return toResponseDTO(optionalRoom.get(), sender);
        }

        ChatRoom chatRoom = ChatRoom.builder()
                .type(type)
                .share(share)
                .build();
        chatRoomRepository.save(chatRoom);

        chatRoomMemberRepository.saveAll(List.of(
                createChatRoomMember(chatRoom, sender, false),
                createChatRoomMember(chatRoom, receiver, false)
        ));
        return toResponseDTO(chatRoom, sender);
    }

    private ChatRoomResponseDto handleGroupChatRoom(ChatRoomRequestDto dto, MultipartFile image, Member creator) {
        String roomName = dto.getChatRoomName();
        if (roomName == null || roomName.trim().isEmpty()) {
            throw new IllegalArgumentException("그룹 채팅방 이름은 필수입니다.");
        }

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "chatrooms");
        }

        ChatRoom chatRoom = ChatRoom.builder()
                .type(Enum.ChatRoomType.GROUP)
                .chatRoomName(roomName)
                .password(dto.getPassword())
                .imageUrl(imageUrl)
                .inviteCode(RandomStringUtils.randomAlphanumeric(10))
                .build();

        chatRoomRepository.save(chatRoom);
        chatRoomMemberRepository.save(createChatRoomMember(chatRoom, creator, true));

        return toResponseDTO(chatRoom, creator);
    }

    public List<ChatRoomResponseDto> getChatRoomsForMember(Member member) {
        List<ChatRoom> chatRooms = chatRoomRepository.findAllByMemberWithMembers(member);

        return chatRooms.stream()
                .sorted(Comparator.comparing(
                        ChatRoom::getLastMessageSentAt,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .map(chatRoom -> toResponseDTO(chatRoom, member))
                .collect(Collectors.toList());
    }

    private ChatRoomResponseDto toResponseDTO(ChatRoom chatRoom, Member currentUser) {
        String otherNickname = null;
        String otherProfileImageUrl = null;
        String sharePostTitle = null;

        ChatRoomMember chatRoomMember = validateChatRoomMember(chatRoom, currentUser);
        Long lastReadMessageId = chatRoomMember.getLastReadMessageId();
        LocalDateTime joinedAt = chatRoomMember.getJoinedAt();

        int unreadCount;
        if (lastReadMessageId == null) {
            // 🔹 처음 입장한 사람 → 입장 이후 메시지만 unread
            unreadCount = messageRepository.countByChatRoomAndSentAtAfterAndSenderNot(chatRoom, joinedAt, currentUser);
        } else {
            // 🔹 기존 유저 → lastReadMessageId 이후 메시지만 unread
            unreadCount = messageRepository.countByChatRoomAndIdGreaterThanAndSentAtAfterAndSenderNot(
                    chatRoom, lastReadMessageId, joinedAt, currentUser);
        }

        if (chatRoom.getType() == Enum.ChatRoomType.DIRECT || chatRoom.getType() == Enum.ChatRoomType.SHARE) {
            Member other = chatRoomMemberRepository.findByChatRoom(chatRoom).stream()
                    .map(ChatRoomMember::getMember)
                    .filter(member -> !member.getId().equals(currentUser.getId()))
                    .findFirst()
                    .orElse(null);

            if (other != null) {
                otherNickname = other.getNickname();
                otherProfileImageUrl = other.getProfileImageUrl();
            }
        }


        if (chatRoom.getType() == Enum.ChatRoomType.SHARE && chatRoom.getShare() != null) {
            sharePostTitle = chatRoom.getShare().getTitle(); // 🔹 제목 가져오기
        }

        return ChatRoomResponseDto.builder()
                .chatRoomId(chatRoom.getId())
                .type(chatRoom.getType())
                .chatRoomName(chatRoom.getChatRoomName())
                .imageUrl(chatRoom.getImageUrl())
                .lastMessage(chatRoom.getLastMessageContent())
                .lastSentAt(chatRoom.getLastMessageSentAt())
                .sharePostId(chatRoom.getShare() != null ? chatRoom.getShare().getId() : null)
                .sharePostTitle(sharePostTitle)
                .otherNickname(otherNickname)
                .otherProfileImageUrl(otherProfileImageUrl)
                .unreadCount(unreadCount)
                .build();
    }

    @Transactional
    public void updateGroupChatRoom(Long chatRoomId, ChatRoomRequestDto dto, MultipartFile image, Member member) {
        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);
        validateAdmin(chatRoom, member);

        if (dto.getChatRoomName() != null) {
            chatRoom.setChatRoomName(dto.getChatRoomName());
        }

        if (dto.getPassword() != null) {
            chatRoom.setPassword(dto.getPassword());
        }
        if (image != null && !image.isEmpty()) {
            if (chatRoom.getImageUrl() != null) {
                fileUploadService.delete(chatRoom.getImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "chatrooms");
            chatRoom.setImageUrl(imageUrl);
        }
        chatRoomRepository.save(chatRoom);
    }

    @Transactional
    public void leaveChatRoom(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateChatRoom(chatRoomId);
        ChatRoomMember chatRoomMember = validateChatRoomMember(chatRoom, member);
        chatRoomMemberRepository.delete(chatRoomMember);

        int remainingMembers = chatRoomMemberRepository.countByChatRoom(chatRoom);
        if (remainingMembers == 0) {
            deleteChatRooom(chatRoom);
        }
    }

    @Transactional
    public void deleteGroupChatRoom(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);
        validateAdmin(chatRoom, member);
        deleteChatRooom(chatRoom);
    }

    @Transactional
    public InviteLinkResponseDto getInviteLink(Long chatRoomId, Member member) {
        ChatRoom chatRoom = validateGroupChatRoom(chatRoomId);

        if (!isMember(chatRoom, member)) {
            throw new AccessDeniedException("해당 채팅방에 속한 멤버만 초대 링크를 조회할 수 있습니다.");
        }

        return new InviteLinkResponseDto(chatRoom.getInviteCode(), "http://localhost:8080/chat/invite/" + chatRoom.getInviteCode());
    }

    @Transactional
    public InviteCheckResponseDto checkInviteAccess(String inviteCode, Member member) {
        ChatRoom chatRoom = validateInviteCode(inviteCode);
        isTypeGroupChatRoom(chatRoom);
        isBannedMember(chatRoom, member);

        return new InviteCheckResponseDto(
                chatRoom.getChatRoomName(),
                isMember(chatRoom, member),
                !isMember(chatRoom, member) && (chatRoom.getPassword() != null && !chatRoom.getPassword().isBlank())
        );
    }

    @Transactional
    public Long enterChatRoomViaInvite(String inviteCode, Member member, String password) {
        ChatRoom chatRoom = validateInviteCode(inviteCode);
        isTypeGroupChatRoom(chatRoom);
        isBannedMember(chatRoom, member);

        if (isMember(chatRoom, member)) {
            return chatRoom.getId();
        }

        String actualPassword = chatRoom.getPassword();
        if (actualPassword != null && !actualPassword.isBlank()) {
            if (!actualPassword.equals(password)) {
                throw new InvalidPasswordException("비밀번호가 일치하지 않습니다.");
            }
        }
        chatRoomMemberRepository.save(createChatRoomMember(chatRoom, member, false));
        return chatRoom.getId();
    }

    public ChatRoom validateGroupChatRoom(Long chatRoomId) {
        ChatRoom chatRoom = validateChatRoom(chatRoomId);
        isTypeGroupChatRoom(chatRoom);
        return chatRoom;
    }

    public ChatRoom validateChatRoom(Long chatRoomId) {
        return chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방을 찾을 수 없습니다."));
    }

    private ChatRoom validateInviteCode(String inviteCode) {
        return chatRoomRepository.findByInviteCode(inviteCode)
                .orElseThrow(() -> new EntityNotFoundException("초대 코드가 유효하지 않습니다."));
    }

    private void isTypeGroupChatRoom(ChatRoom chatRoom) {
        if (chatRoom.getType() != Enum.ChatRoomType.GROUP) {
            throw new InvalidChatRoomOperationException("그룹 채팅방이 아닙니다.");
        }
    }

    private void deleteChatRooom(ChatRoom chatRoom) {
        if (chatRoom.getImageUrl() != null) {
            fileUploadService.delete(chatRoom.getImageUrl());
        }
        chatRoomRepository.delete(chatRoom);
    }

    private Share validateSharePost(Enum.ChatRoomType type, Long shareId) {
        if (type == Enum.ChatRoomType.SHARE) {
            if (shareId == null) {
                throw new IllegalArgumentException("나눔 채팅방은 shareId가 필요합니다.");
            }
            return shareRepository.findById(shareId)
                    .orElseThrow(() -> new ResourceNotFoundException("해당 나눔글이 존재하지 않습니다."));
        } else {
            return null;
        }
    }

    public ChatRoomMember createChatRoomMember(ChatRoom chatRoom, Member member, boolean isAdmin) {
        return ChatRoomMember.builder()
                .chatRoom(chatRoom)
                .member(member)
                .isAdmin(isAdmin)
                .build();
    }

    public ChatRoomMember validateChatRoomMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.findByChatRoomAndMember(chatRoom, member)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방 멤버가 아닙니다."));
    }

    public boolean isMember(ChatRoom chatRoom, Member member) {
        return chatRoomMemberRepository.existsByChatRoomAndMember(chatRoom, member);
    }

    public ChatRoomMember validateAdmin(ChatRoom chatRoom, Member member) {
        ChatRoomMember chatRoomMember = validateChatRoomMember(chatRoom, member);
        if (!chatRoomMember.isAdmin()) {
            throw new AccessDeniedException("당신은 관리자가 아닙니다.");
        }
        return chatRoomMember;
    }

    public void isBannedMember(ChatRoom chatRoom, Member member) {
        if (chatRoomBanRepository.existsByChatRoomAndBannedMember(chatRoom, member)) {
            throw new AccessDeniedException("이 채팅방에서 차단된 사용자입니다.");
        }
    }

    // 안읽은 총 메시지 수
    public int getTotalUnreadCount(Member member) {
        List<ChatRoomMember> joinedRooms = chatRoomMemberRepository.findByMember(member);

        int totalUnread = 0;
        for (ChatRoomMember crm : joinedRooms) {
            int unread = messageRepository.countUnreadMessagesForMember(
                    crm.getChatRoom().getId(),
                    member.getId()
            );
            totalUnread += unread;
        }

        return totalUnread;
    }

    public ChatRoomResponseDto getChatRoomDetail(Long chatRoomId, Member member) {
        ChatRoom chatRoom = chatRoomRepository.findById(chatRoomId)
                .orElseThrow(() -> new ResourceNotFoundException("채팅방을 찾을 수 없습니다."));

        validateChatRoomMember(chatRoom, member);

        return toResponseDTO(chatRoom, member);
    }
}
