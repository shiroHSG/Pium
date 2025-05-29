package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.MateRequestRepository;
import com.buddy.pium.repository.common.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Objects;

@Service
@Transactional
@RequiredArgsConstructor
public class MateRequestService {

    private final MateRequestRepository mateRequestRepository;
    private final MemberRepository memberRepository;

    public MateRequest sendRequest(Long senderId, Long receiverId) {
        if (Objects.equals(senderId, receiverId)) {
            throw new IllegalArgumentException("자기 자신에게는 배우자 요청을 보낼 수 없습니다.");
        }

        Member sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("보내는 사용자가 존재하지 않습니다."));
        Member receiver = memberRepository.findById(receiverId)
                .orElseThrow(() -> new IllegalArgumentException("받는 사용자가 존재하지 않습니다."));

        boolean exists = mateRequestRepository
                .findBySenderAndReceiverAndStatus(sender, receiver, MateRequestStatus.PENDING)
                .isPresent();
        if (exists) {
            throw new IllegalStateException("이미 신청 중인 요청이 존재합니다.");
        }

        MateRequest request = MateRequest.builder()
                .sender(sender)
                .receiver(receiver)
                .build();

        return mateRequestRepository.save(request);
    }

    public List<MateRequest> getReceivedRequests(Long memberId) {
        Member receiver = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        return mateRequestRepository.findByReceiverAndStatus(receiver, MateRequestStatus.PENDING);
    }

    public List<MateRequest> getSentRequests(Long memberId) {
        Member sender = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));
        return mateRequestRepository.findBySender(sender);
    }

    public void acceptRequest(Long requestId) {
        MateRequest request = mateRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("요청을 찾을 수 없습니다."));

        Member sender = request.getSender();
        Member receiver = request.getReceiver();

        if (Objects.equals(sender.getId(), receiver.getId())) {
            throw new IllegalStateException("동일 사용자끼리는 배우자 연결할 수 없습니다.");
        }

        if (Objects.equals(sender.getMateInfo(), String.valueOf(receiver.getId())) &&
                Objects.equals(receiver.getMateInfo(), String.valueOf(sender.getId()))) {
            throw new IllegalStateException("이미 배우자로 연결되어 있습니다.");
        }

        sender.setMateInfo(Long.valueOf(String.valueOf(receiver.getId())));
        receiver.setMateInfo(Long.valueOf(String.valueOf(sender.getId())));
        memberRepository.save(sender);
        memberRepository.save(receiver);

        request.setStatus(MateRequestStatus.ACCEPTED);
        mateRequestRepository.save(request); // 상태 저장
    }

    public void rejectRequest(Long requestId) {
        MateRequest request = mateRequestRepository.findById(requestId)
                .orElseThrow(() -> new IllegalArgumentException("요청을 찾을 수 없습니다."));
        request.setStatus(MateRequestStatus.REJECTED);
        mateRequestRepository.save(request); // 상태 저장
    }
}