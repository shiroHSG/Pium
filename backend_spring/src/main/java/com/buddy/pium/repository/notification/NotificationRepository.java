package com.buddy.pium.repository.notification;

import com.buddy.pium.entity.notification.Notification;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    List<Notification> findByReceiverIdAndIsReadFalseOrderByCreatedAtDesc(Long memberId);

    int countByReceiverIdAndIsReadFalse(Long receiverId);

    Optional<Notification> findByTypeAndReceiverIdAndTargetId(String mateRequest, Long id, Long id1);
}
