package com.buddy.pium.dto.share;

import lombok.Getter;
import lombok.Setter;
import com.fasterxml.jackson.annotation.JsonProperty;

@Getter
@Setter
public class ShareRequestDto {
    private String title;
    private String content;

    @JsonProperty("category")
    private String category;
}
