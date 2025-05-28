package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.common.MemberChild;
import com.buddy.pium.repository.common.ChildRepository;
import com.buddy.pium.repository.common.MemberChildRepository;
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
    private final MemberChildRepository memberChildRepository;
    private final MemberRepository memberRepository;

    // 단독 자녀 저장 (Mate 자동 공유 없음)
    public Child save(Child child) {
        return childRepository.save(child);
    }

    // 자녀 저장 + 배우자 양방향 설정 확인 후 자동 공유
    public Child saveChildWithSpouseLink(Member member, Child child) {
        Child saved = childRepository.save(child);

        // 본인과 연결
        MemberChild link = MemberChild.builder()
                .member(member)
                .child(saved)
                .relationType(null)
                .build();
        memberChildRepository.save(link);

        // 양방향 mateInfo 연결된 경우 배우자도 자동 연결
        getMateIfMutuallyConnected(member).ifPresent(mate -> {
            boolean alreadyLinked = memberChildRepository
                    .findByMemberAndChild(mate, saved)
                    .isPresent();
            if (!alreadyLinked) {
                MemberChild mateLink = MemberChild.builder()
                        .member(mate)
                        .child(saved)
                        .relationType(null)
                        .build();
                memberChildRepository.save(mateLink);
            }
        });

        return saved;
    }

    // 본인 + 배우자 자녀 목록 (양방향 mateInfo 연결 시만 공유)
    public List<Child> findAllChildrenForMember(Member member) {
        Set<Child> result = new HashSet<>();

        memberChildRepository.findByMember(member)
                .forEach(mc -> result.add(mc.getChild()));

        getMateIfMutuallyConnected(member).ifPresent(mate -> {
            memberChildRepository.findByMember(mate)
                    .forEach(mc -> result.add(mc.getChild()));
        });

        return new ArrayList<>(result);
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
