package com.buddy.pium.service;

import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FileUploadService {

    @Value("${file.upload-dir}")
    private String uploadDir;

    public String upload(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        try {
            String extension = getFileExtension(file.getOriginalFilename());    //확장자 추출
            String fileName = UUID.randomUUID() + extension;

            String fullPath = Paths.get(uploadDir, folder).toString() + "/";

            File directory = new File(fullPath);
            if (!directory.exists()) {
                directory.mkdirs();
            }

            File saveFile = new File(fullPath + fileName);
            file.transferTo(saveFile);

            // URL 경로로 반환
            return "/uploads/" + folder + "/" + fileName;

        } catch (IOException e) {
            throw new RuntimeException("파일 업로드 실패", e);
        }
    }

    public void delete(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return;
        }
        try {
            String relativePath = fileUrl.replaceFirst("^/uploads/", "");

            Path path = Paths.get(uploadDir, relativePath); // ✅ OS 경로 조합
            Files.deleteIfExists(path);

            System.out.println("✅ 파일 삭제 완료: " + path.toAbsolutePath());
        } catch (IOException e) {
            System.out.println("❌ 파일 삭제 실패: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf(".");
        return (dotIndex != -1) ? fileName.substring(dotIndex) : "";
    }
}
