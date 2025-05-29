package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.*;

@Service
@Transactional
@RequiredArgsConstructor
public class ChildService {

    private final ChildRepository childRepository;
    private final MemberRepository memberRepository;

    // 단독 자녀 저장 (Mate 자동 공유 없음)
    public Child save(Child child) {
        return childRepository.save(child);
    }

    // 자녀 이름으로 검색
    public List<Child> searchByName(String keyword) {
        return childRepository.findByNameContaining(keyword);
    }

    public Optional<Child> findById(Long id) {
        return childRepository.findById(id);
    }

    public List<Child> findAll() {
        return childRepository.findAll();
    }

    public void delete(Long id) {
        childRepository.deleteById(id);
    }

    // 양방향 mateInfo 연결 여부 확인
    private Optional<Member> getMateIfMutuallyConnected(Member member) {
        if (member.getMateInfo() == null) return Optional.empty();

        return memberRepository.findById(Long.valueOf(member.getMateInfo()))
                .filter(mate -> String.valueOf(member.getId()).equals(mate.getMateInfo()));
    }
}
