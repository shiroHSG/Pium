package com.buddy.pium.service.policy;

import com.buddy.pium.dto.policy.PolicyResponseDto;
import com.buddy.pium.entity.policy.Policy;
import com.buddy.pium.exception.PolicyNotFoundException;
import com.buddy.pium.repository.policy.PolicyRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.*;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class PolicyService {

    @Autowired
    private PolicyRepository policyRepository;

    public Page<PolicyResponseDto> getAllPolicies(int page, int size, String sortBy) {
        Sort sort = getSort(sortBy);
        Pageable pageable = PageRequest.of(page, size, sort);
        Page<Policy> policyPage = policyRepository.findAll(pageable);
        return policyPage.map(PolicyResponseDto::fromEntity);
    }

    public PolicyResponseDto getPolicyById(Long id) {
        Policy policy = policyRepository.findById(id)
                .orElseThrow(() -> new PolicyNotFoundException(id));
        if(policy.getViewCount()== null)
            policy.setViewCount(1L);
        else {
            policy.setViewCount(policy.getViewCount() + 1);
        }
        policyRepository.save(policy);

        return PolicyResponseDto.fromEntity(policy);
    }

    public Page<PolicyResponseDto> searchPolicies(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by(Sort.Direction.DESC, "createdAt"));
        Page<Policy> result = policyRepository.searchByKeyword(keyword, pageable);
        return result.map(PolicyResponseDto::fromEntity);
    }


    private Sort getSort(String sortBy) {
        return switch (sortBy) {
            case "oldest" -> Sort.by(Sort.Direction.ASC, "createdAt");
            case "views" -> Sort.by(Sort.Direction.DESC, "viewCount");
            default -> Sort.by(Sort.Direction.DESC, "createdAt");
        };
    }
}
