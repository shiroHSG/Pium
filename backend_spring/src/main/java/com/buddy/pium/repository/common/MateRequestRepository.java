package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;
import java.util.List;

public interface MateRequestRepository extends JpaRepository<MateRequest, Long> {

    // 특정 상태의 Mate 요청 존재 여부 확인
    boolean existsBySenderAndReceiverAndStatus(Member sender, Member receiver, MateRequestStatus status);

    // 특정 상태의 Mate 요청 단건 조회 (Id 기반)
    Optional<MateRequest> findBySenderIdAndReceiverIdAndStatus(Long senderId, Long receiverId, MateRequestStatus status);

    // 특정 상태의 요청 리스트 (받은 요청 기준)
    List<MateRequest> findByReceiverAndStatus(Member receiver, MateRequestStatus status);

    // 특정 상태의 요청 리스트 (보낸 요청 기준)
    List<MateRequest> findBySenderAndStatus(Member sender, MateRequestStatus status);

}
