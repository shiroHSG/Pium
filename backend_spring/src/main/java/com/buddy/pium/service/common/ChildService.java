package com.buddy.pium.service.common;

import com.buddy.pium.entity.common.Child;
import com.buddy.pium.repository.common.ChildRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ChildService {

    private final ChildRepository childRepository;

    // 자녀 전체 조회
    public List<Child> getAllChildren() {
        return childRepository.findAll();
    }

    // 특정 자녀 조회
    public Optional<Child> getChildById(Long id) {
        return childRepository.findById(id);
    }

    // 특정 부모의 자녀 목록 조회
    public List<Child> getChildrenByMemberId(Long memberId) {
        return childRepository.findByMemberId(memberId);
    }

    // 자녀 등록
    public Child addChild(Child child) {
        return childRepository.save(child);
    }

    // 자녀 수정
    public Optional<Child> updateChild(Long id, Child updatedChild) {
        return childRepository.findById(id).map(child -> {
            child.setName(updatedChild.getName());
            child.setBirth(updatedChild.getBirth());
            child.setGender(updatedChild.getGender());
            child.setMember(updatedChild.getMember()); // 관계 업데이트
            return childRepository.save(child);
        });
    }

    // 자녀 삭제
    public void deleteChild(Long id) {
        childRepository.deleteById(id);
    }
}
