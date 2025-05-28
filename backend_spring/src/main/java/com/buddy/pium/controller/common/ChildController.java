package com.buddy.pium.controller.common;

import com.buddy.pium.entity.common.Child;
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

    @PostMapping("/register")
    public ResponseEntity<Child> create(@RequestBody Child child) {
        return ResponseEntity.ok(childService.save(child));
    }

    @GetMapping("/{id}")
    public ResponseEntity<Child> getById(@PathVariable Long id) {
        return childService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping
    public ResponseEntity<List<Child>> getAll() {
        return ResponseEntity.ok(childService.findAll());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        childService.delete(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/search")
    public ResponseEntity<List<Child>> searchByName(@RequestParam String name) {
        return ResponseEntity.ok(childService.searchByName(name));
    }
}
