package com.buddy.pium.controller.common;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.service.common.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    @GetMapping("/get/{id}")
    public ResponseEntity<Member> getById(@PathVariable Long id) {
        System.out.println(id);
        return memberService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping("/add")
    public ResponseEntity<Member> create(@RequestBody Member member) {
        return ResponseEntity.ok(memberService.save(member));
    }

    @GetMapping
    public ResponseEntity<List<Member>> getAll() {
        return ResponseEntity.ok(memberService.findAll());
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        memberService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/edit/{id}")
    public ResponseEntity<Member> updateMember(@PathVariable Long id, @RequestBody Member updatedMember) {
        Optional<Member> memberOptional = memberService.findById(id);
        if (memberOptional.isPresent()) {
            Member member = memberOptional.get();

            if (updatedMember.getUsername() != null) member.setUsername(updatedMember.getUsername());
            if (updatedMember.getNickname() != null) member.setNickname(updatedMember.getNickname());
            if (updatedMember.getEmail() != null) member.setEmail(updatedMember.getEmail());
            if (updatedMember.getPassword() != null) member.setPassword(updatedMember.getPassword());
            if (updatedMember.getAddress() != null) member.setAddress(updatedMember.getAddress());
            if (updatedMember.getBirth() != null) member.setBirth(updatedMember.getBirth());
            if (updatedMember.getPhoneNumber() != null) member.setPhoneNumber(updatedMember.getPhoneNumber());
            if (updatedMember.getProfileImage() != null) member.setProfileImage(updatedMember.getProfileImage());
            if (updatedMember.getMateInfo() != null) member.setMateInfo(updatedMember.getMateInfo());

            return ResponseEntity.ok(memberService.save(member));
        } else {
            return ResponseEntity.notFound().build();
        }
    }

}
