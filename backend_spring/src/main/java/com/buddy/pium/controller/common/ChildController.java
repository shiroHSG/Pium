package com.buddy.pium.controller.common;

import com.buddy.pium.annotation.CurrentMember;
import com.buddy.pium.annotation.CurrentMemberId;
import com.buddy.pium.dto.common.ChildRegisterDto;
import com.buddy.pium.dto.common.ChildResponseDto;
import com.buddy.pium.dto.common.ChildUpdateDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.ChildService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/child")
@RequiredArgsConstructor
public class ChildController {

    private final ChildService childService;

    @PostMapping
    public ResponseEntity<?> addChild(@RequestBody ChildRegisterDto dto,
                                      @CurrentMemberId Long memberId) {
        childService.addChild(dto, memberId);
        return ResponseEntity.ok("아이 등록이 완료되었습니다.");
    }

    @DeleteMapping("/{childId}")
    public ResponseEntity<?> deleteChild(@PathVariable Long childId,
                                         @CurrentMemberId Long memberId) {
        childService.deleteChild(childId, memberId);
        return ResponseEntity.ok("아이를 삭제했습니다.");
    }

    @PatchMapping("/{childId}")
    public ResponseEntity<?> updateChild(@PathVariable Long childId,
                                         @RequestBody ChildUpdateDto dto,
                                         @CurrentMemberId Long memberId) {
        childService.updateChild(childId, dto, memberId);
        return ResponseEntity.ok("아이 정보를 수정했습니다.");
    }

    @GetMapping("/{childId}")
    public ResponseEntity<ChildResponseDto> getChildById(@PathVariable Long childId,
                                                         @CurrentMemberId Long memberId) {
        ChildResponseDto child = childService.getChildById(childId, memberId);
        return ResponseEntity.ok(child);
    }

    @GetMapping
    public ResponseEntity<List<ChildResponseDto>> getChildren(@CurrentMember Member member) {
        Long memberId = member.getId();
        Long mateId = member.getMateInfo(); // mateInfo가 null이면 null로 처리됨
        return ResponseEntity.ok(childService.getChildren(memberId, mateId));
    }
}
