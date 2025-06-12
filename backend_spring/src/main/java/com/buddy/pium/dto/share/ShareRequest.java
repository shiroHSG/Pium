package com.buddy.pium.dto.share;

import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class ShareRequest {
    private String title;
    private String content;
    private String imgUrl;
}
