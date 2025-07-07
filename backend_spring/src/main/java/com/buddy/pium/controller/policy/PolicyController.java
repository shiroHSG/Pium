package com.buddy.pium.controller.policy;

import com.buddy.pium.dto.policy.PolicyResponseDto;
import com.buddy.pium.service.policy.PolicyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/policies")
public class PolicyController {

    @Autowired
    private PolicyService policyService;

    @GetMapping
    public Page<PolicyResponseDto> getAllPolicies(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size,
            @RequestParam(defaultValue = "latest") String sortBy
    ) {
        return policyService.getAllPolicies(page, size, sortBy);
    }

    @GetMapping("/{id}")
    public PolicyResponseDto getPolicyById(@PathVariable Long id) {
        return policyService.getPolicyById(id);
    }

    @GetMapping("/search")
    public Page<PolicyResponseDto> searchPolicies(
            @RequestParam String keyword,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        return policyService.searchPolicies(keyword, page, size);
    }

    @GetMapping("/popular")
    public PolicyResponseDto getMostPopularPolicy() {
        return policyService.getMostPopularPolicy();
    }
}
