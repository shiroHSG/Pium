package com.buddy.pium.controller.common;

import com.buddy.pium.entity.common.Child;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.common.MemberChild;
import com.buddy.pium.service.common.ChildService;
import com.buddy.pium.service.common.MemberChildService;
import com.buddy.pium.service.common.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/member-child")
@RequiredArgsConstructor
public class MemberChildController {

    private final MemberChildService memberChildService;
    private final MemberService memberService;
    private final ChildService childService;

    @PostMapping
    public ResponseEntity<MemberChild> create(@RequestBody MemberChild memberChild) {
        return ResponseEntity.ok(memberChildService.save(memberChild));
    }

    @GetMapping("/member/{memberId}")
    public ResponseEntity<List<MemberChild>> getByMember(@PathVariable Long memberId) {
        Member member = memberService.findById(memberId).orElse(null);
        return member == null ?
                ResponseEntity.notFound().build() :
                ResponseEntity.ok(memberChildService.findByMember(member));
    }

    @GetMapping("/child/{childId}")
    public ResponseEntity<List<MemberChild>> getByChild(@PathVariable Long childId) {
        Child child = childService.findById(childId).orElse(null);
        return child == null ?
                ResponseEntity.notFound().build() :
                ResponseEntity.ok(memberChildService.findByChild(child));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        memberChildService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
