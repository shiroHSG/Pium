package com.buddy.pium.controller.common;

import com.buddy.pium.dto.common.*;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.service.common.ChildService;
import com.buddy.pium.util.JwtUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/child")
@RequiredArgsConstructor
public class ChildController {

    private final MemberRepository memberRepository;
    private final ChildService childService;
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public ResponseEntity<?> addChild(@RequestBody ChildRegisterDto dto, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        childService.addChild(dto, memberId);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{childId}")
    public ResponseEntity<?> deleteChild(@PathVariable Long childId, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        childService.deleteChild(childId, memberId);
        return ResponseEntity.ok().build();
    }

    @PutMapping("/{childId}")
    public ResponseEntity<?> updateChild(@PathVariable Long childId,
                                         @RequestBody ChildUpdateDto dto,
                                         Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        childService.updateChild(childId, dto, memberId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/me")
    public ResponseEntity<List<ChildResponseDto>> getChildren(Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        Long mateId = memberRepository.findById(memberId)
                .map(Member::getMateInfo)
                .orElse(null);
        return ResponseEntity.ok(childService.getChildren(memberId, mateId));
    }
}