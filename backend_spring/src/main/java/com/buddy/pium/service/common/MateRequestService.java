package com.buddy.pium.service.common;

import com.buddy.pium.dto.common.MateResponseDto;
import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.MateRequestRepository;
import com.buddy.pium.repository.common.MemberRepository;
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

    @Transactional
    public void requestMate(Long senderId, Long receiverId) {
        if (senderId.equals(receiverId)) {
            throw new IllegalArgumentException("자기 자신에게 Mate 요청을 보낼 수 없습니다.");
        }

        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("요청자 정보를 찾을 수 없습니다."));
        Member receiver = memberRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("상대방 정보를 찾을 수 없습니다."));

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
    }

    @Transactional
    public void acceptMateBySender(Long senderId, Long receiverId) {
        MateRequest request = mateRequestRepository
                .findBySenderIdAndReceiverIdAndStatus(senderId, receiverId, MateRequestStatus.PENDING)
                .orElseThrow(() -> new IllegalArgumentException("해당 Mate 요청이 존재하지 않거나 이미 처리되었습니다."));

        Member sender = request.getSender();
        Member receiver = request.getReceiver();

        if (sender.getMateInfo() != null || receiver.getMateInfo() != null) {
            throw new IllegalStateException("이미 Mate가 설정된 사용자입니다.");
        }

        sender.setMateInfo(receiver.getId());
        receiver.setMateInfo(sender.getId());

        memberRepository.save(sender);
        memberRepository.save(receiver);

        request.setStatus(MateRequestStatus.ACCEPTED);
    }

    @Transactional
    public void rejectMateBySender(Long senderId, Long receiverId) {
        MateRequest request = mateRequestRepository
                .findBySenderIdAndReceiverIdAndStatus(senderId, receiverId, MateRequestStatus.PENDING)
                .orElseThrow(() -> new IllegalArgumentException("해당 Mate 요청이 존재하지 않거나 이미 처리되었습니다."));

        request.setStatus(MateRequestStatus.REJECTED);
    }

    public List<MateResponseDto> getPendingRequests(Long receiverId) {
        Member receiver = memberRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("회원 정보를 찾을 수 없습니다."));

        return mateRequestRepository.findByReceiverAndStatus(receiver, MateRequestStatus.PENDING)
                .stream()
                .map(req -> MateResponseDto.builder()
                        .requestId(req.getId())
                        .senderId(req.getSender().getId())
                        .senderNickname(req.getSender().getNickname())
                        .status(req.getStatus())
                        .updatedAt(req.getUpdatedAt())
                        .message("Mate 요청 대기 중")
                        .build())
                .collect(Collectors.toList());
    }

    public List<MateResponseDto> getSentRequests(Long senderId) {
        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("회원 정보를 찾을 수 없습니다."));

        return mateRequestRepository.findBySenderAndStatus(sender, MateRequestStatus.PENDING)
                .stream()
                .map(req -> MateResponseDto.builder()
                        .requestId(req.getId())
                        .senderId(req.getSender().getId())
                        .senderNickname(req.getSender().getNickname())
                        .status(req.getStatus())
                        .updatedAt(req.getUpdatedAt())
                        .message("보낸 Mate 요청 대기 중")
                        .build())
                .collect(Collectors.toList());
    }

    @Transactional
    public void cancelRequest(Long senderId, Long receiverId) {
        MateRequest request = mateRequestRepository
                .findBySenderIdAndReceiverIdAndStatus(senderId, receiverId, MateRequestStatus.PENDING)
                .orElseThrow(() -> new IllegalArgumentException("해당 Mate 요청이 존재하지 않거나 이미 처리되었습니다."));

        mateRequestRepository.delete(request);
    }

    @Transactional
    public void disconnectMate(Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("회원 정보를 찾을 수 없습니다."));

        if (member.getMateInfo() == null) {
            throw new IllegalStateException("Mate가 설정되어 있지 않습니다.");
        }

        Member mate = memberRepository.findById(member.getMateInfo())
                .orElseThrow(() -> new IllegalArgumentException("상대 Mate 정보를 찾을 수 없습니다."));

        member.setMateInfo(null);
        mate.setMateInfo(null);

        memberRepository.save(member);
        memberRepository.save(mate);
    }
}
