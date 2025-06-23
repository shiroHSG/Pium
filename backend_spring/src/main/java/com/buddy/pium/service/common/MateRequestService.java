package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.MateResponseDto;
import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MateRequestRepository;
import com.buddy.pium.repository.common.MemberRepository;
//import com.buddy.pium.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class MateRequestService {

    private final MateRequestRepository mateRequestRepository;
    private final MemberRepository memberRepository;
//    private final NotificationService notificationService;

    @Transactional
    public void requestMate(Member sender, Long receiverId) {
        Member receiver = validateMember(receiverId);
        if(sender.equals(receiver)) {
            throw new IllegalArgumentException("자기 자신에게 Mate 요청을 보낼 수 없습니다.");
        }

        if (sender.getMateInfo() != null || receiver.getMateInfo() != null) {
            throw new IllegalStateException("상대방 또는 본인은 이미 Mate로 연결되어 있습니다.");
        }

        boolean exists = mateRequestRepository.existsBySenderAndReceiverAndStatus(
                sender, receiver, MateRequestStatus.PENDING);
        if (exists) {
            throw new IllegalStateException("이미 Mate 요청을 보낸 상태입니다.");
        }

        MateRequest request = MateRequest.builder()
                .sender(sender)
                .receiver(receiver)
                .status(MateRequestStatus.PENDING)
                .build();

        mateRequestRepository.save(request);
/*
        // 알림 전송
        notificationService.sendNotification(
                receiverId,
                sender.getNickname() + "님이 Mate 요청을 보냈습니다.",
                "MATE_REQUEST",
                "MEMBER",
                sender.getId()
        );
        */
    }

    // 수락
    @Transactional
    public void acceptMateByRequestId(Long requestId, Member receiver) {
        MateRequest request = mateRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("해당 Mate 요청이 존재하지 않습니다."));

        if (!request.getReceiver().getId().equals(receiver.getId())) {
            throw new SecurityException("자신에게 온 Mate 요청만 수락할 수 있습니다.");
        }

        Member sender = request.getSender();

        if (sender.getMateInfo() != null || receiver.getMateInfo() != null) {
            throw new IllegalStateException("이미 Mate가 설정된 사용자입니다.");
        }

        sender.setMateInfo(receiver.getId());
        receiver.setMateInfo(sender.getId());

        memberRepository.save(sender);
        memberRepository.save(receiver);

        request.setStatus(MateRequestStatus.ACCEPTED);
    }


    // 거절
    @Transactional
    public void rejectMateByRequestId(Long requestId, Member receiver) {
        MateRequest request = mateRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("해당 Mate 요청이 존재하지 않습니다."));

        if (!request.getReceiver().getId().equals(receiver.getId())) {
            throw new SecurityException("자신에게 온 Mate 요청만 거절할 수 있습니다.");
        }

        request.setStatus(MateRequestStatus.REJECTED);
    }


    public List<MateResponseDto> getPendingRequests(Member receiver) {
        return mateRequestRepository.findByReceiverAndStatus(receiver, MateRequestStatus.PENDING)
                .stream()
                .map(req -> MateResponseDto.builder()
                        .requestId(req.getId())
                        .senderId(req.getSender().getId())
                        .senderUsername(req.getSender().getUsername())
                        .senderNickname(req.getSender().getNickname())
                        .status(req.getStatus())
                        .updatedAt(req.getUpdatedAt())
                        .message("Mate 요청 대기 중")
                        .build())
                .collect(Collectors.toList());
    }

    public List<MateResponseDto> getSentRequests(Member sender) {
        return mateRequestRepository.findBySenderAndStatus(sender, MateRequestStatus.PENDING)
                .stream()
                .map(req -> MateResponseDto.builder()
                        .requestId(req.getId())
                        .receiverId(req.getReceiver().getId()) // ✅
                        .receiverUsername(req.getReceiver().getUsername()) // ✅
                        .receiverNickname(req.getReceiver().getNickname()) // ✅
                        .status(req.getStatus())
                        .updatedAt(req.getUpdatedAt())
                        .message("보낸 Mate 요청 대기 중")
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void cancelRequest(Member sender, Long requestId) {
        MateRequest request = mateRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("요청이 존재하지 않습니다."));

        // 보낸 사람 확인
        if (!request.getSender().getId().equals(sender.getId())) {
            throw new IllegalArgumentException("본인이 보낸 요청만 취소할 수 있습니다.");
        }
        mateRequestRepository.delete(request);
    }

    @Transactional
    public void disconnectMate(Member member) {
        if (member.getMateInfo() == null) {
            throw new IllegalArgumentException("Mate가 설정되어 있지 않습니다.");
        }

        Member mate = memberRepository.findById(member.getMateInfo())
                .orElseThrow(() -> new IllegalArgumentException("상대 Mate 정보를 찾을 수 없습니다."));

        member.setMateInfo(null);
        mate.setMateInfo(null);

        memberRepository.save(member);
        memberRepository.save(mate);
    }

    public Member validateMember(Long memberId) {
        return memberRepository.findById(memberId)
                .orElseThrow(() -> new ResourceNotFoundException("회원 정보를 찾을 수 없습니다."));
    }
}
