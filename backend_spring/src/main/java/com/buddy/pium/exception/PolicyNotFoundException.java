package com.buddy.pium.exception;

public class PolicyNotFoundException extends RuntimeException {
    public PolicyNotFoundException(Long id) {
        super("없는 id입니다: " + id);
    }
}
