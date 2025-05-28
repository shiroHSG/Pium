package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.common.MemberChild;
import com.buddy.pium.repository.common.MemberChildRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
@RequiredArgsConstructor
public class MemberChildService {

    private final MemberChildRepository memberChildRepository;

    public MemberChild save(MemberChild memberChild) {
        return memberChildRepository.save(memberChild);
    }

    public List<MemberChild> findByMember(Member member) {
        return memberChildRepository.findByMember(member);
    }

    public List<MemberChild> findByChild(Child child) {
        return memberChildRepository.findByChild(child);
    }

    public Optional<MemberChild> findByMemberAndChild(Member member, Child child) {
        return memberChildRepository.findByMemberAndChild(member, child);
    }

    public void delete(Long id) {
        memberChildRepository.deleteById(id);
    }
}
