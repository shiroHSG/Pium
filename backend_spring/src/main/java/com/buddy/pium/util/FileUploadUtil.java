package com.buddy.pium.util;

import org.springframework.stereotype.Component;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.UUID;

@Component
public class FileUploadUtil {

    private static final String UPLOAD_DIR = "C:/upload/";

    public String saveFile(MultipartFile file) {
        if (file.isEmpty()) return null;

        String originalFilename = file.getOriginalFilename();
        String ext = originalFilename.substring(originalFilename.lastIndexOf("."));
        String newFilename = UUID.randomUUID() + ext;
        File savePath = new File(UPLOAD_DIR, newFilename);

        try {
            file.transferTo(savePath);
        } catch (IOException e) {
            throw new RuntimeException("파일 저장 실패", e);
        }

        return "/upload/" + newFilename;
    }
}

