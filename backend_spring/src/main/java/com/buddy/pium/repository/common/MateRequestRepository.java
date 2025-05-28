package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.common.MateRequest;
import com.buddy.pium.entity.common.Enum.MateRequestStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MateRequestRepository extends JpaRepository<MateRequest, Long> {

    List<MateRequest> findByReceiverAndStatus(Member receiver, MateRequestStatus status);

    List<MateRequest> findBySender(Member sender);

    Optional<MateRequest> findBySenderAndReceiverAndStatus(Member sender, Member receiver, MateRequestStatus status);
}
