package com.buddy.pium.controller.share;

import com.buddy.pium.dto.share.ShareRequest;
import com.buddy.pium.dto.share.ShareResponse;
import com.buddy.pium.service.share.ShareService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequiredArgsConstructor
@RequestMapping("/api/shares")
public class ShareController {

    private final ShareService shareService;

    @PostMapping
    public ResponseEntity<Void> create(@RequestBody ShareRequest dto, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        shareService.create(dto, memberId);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/{id}")
    public ResponseEntity<ShareResponse> get(@PathVariable Long id, Authentication auth) {
        return ResponseEntity.ok(shareService.get(id));
    }

    @GetMapping
    public ResponseEntity<List<ShareResponse>> getAll(Authentication auth) {
        return ResponseEntity.ok(shareService.getAll());
    }

    @PutMapping("/{id}")
    public ResponseEntity<Void> update(@PathVariable Long id,
                                       @RequestBody ShareRequest dto,
                                       Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        shareService.update(id, memberId, dto);
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id, Authentication auth) {
        Long memberId = (Long) auth.getPrincipal();
        shareService.delete(id, memberId);
        return ResponseEntity.ok().build();
    }


}
