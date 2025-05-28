package com.buddy.pium.repository.common;

import com.buddy.pium.entity.common.MemberChild;
import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface MemberChildRepository extends JpaRepository<MemberChild, Long> {

    List<MemberChild> findByMember(Member member);
    List<MemberChild> findByChild(Child child);

    Optional<MemberChild> findByMemberAndChild(Member member, Child child);
}
