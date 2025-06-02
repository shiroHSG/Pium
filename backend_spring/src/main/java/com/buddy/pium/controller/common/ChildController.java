package com.buddy.pium.controller.common;

import com.buddy.pium.dto.common.ChildRequestDto;
import com.buddy.pium.dto.common.ChildResponseDto;
import com.buddy.pium.service.common.ChildService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/child")
@RequiredArgsConstructor
public class ChildController {

    private final ChildService childService;

    @PostMapping
    public ResponseEntity<ChildResponseDto> create(@RequestBody ChildRequestDto dto, Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(childService.createChild(memberId, dto));
    }

    @PutMapping("/{id}")
    public ResponseEntity<ChildResponseDto> update(@PathVariable Long id,
                                                   @RequestBody ChildRequestDto dto,
                                                   Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(childService.updateChild(memberId, id, dto));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        childService.deleteChild(memberId, id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ChildResponseDto> getOne(@PathVariable Long id, Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(childService.getChild(memberId, id));
    }

    @GetMapping
    public ResponseEntity<List<ChildResponseDto>> getAll(Authentication authentication) {
        Long memberId = (Long) authentication.getPrincipal();
        return ResponseEntity.ok(childService.getAllChildren(memberId));
    }
}
