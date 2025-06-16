package com.buddy.pium.repository.calender;

import com.buddy.pium.entity.calender.Calender;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface CalenderRepository extends JpaRepository<Calender, Long> {
    List<Calender> findByMemberId(Long memberId);

    List<Calender> findByMember(Member member);
}
