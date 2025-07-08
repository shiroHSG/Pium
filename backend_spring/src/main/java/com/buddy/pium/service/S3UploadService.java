package com.buddy.pium.service;

import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.model.*;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class S3UploadService {

    private final AmazonS3 amazonS3;

    @Value("${cloud.aws.s3.bucket-name}")
    private String bucketName;

    public String upload(MultipartFile file, String folder) {
        if (file == null || file.isEmpty()) {
            return null;
        }

        try {
            String extension = getFileExtension(file.getOriginalFilename());
            String fileName = folder + "/" + UUID.randomUUID() + extension;

            ObjectMetadata metadata = new ObjectMetadata();
            metadata.setContentType(file.getContentType());
            metadata.setContentLength(file.getSize());

            amazonS3.putObject(new PutObjectRequest(
                    bucketName,
                    fileName,
                    file.getInputStream(),
                    metadata
            ).withCannedAcl(CannedAccessControlList.PublicRead)); // 🔓 퍼블릭으로 설정

            // 접근 가능한 URL 반환
            return amazonS3.getUrl(bucketName, fileName).toString();

        } catch (IOException e) {
            throw new RuntimeException("S3 파일 업로드 실패", e);
        }
    }

    public void delete(String fileUrl) {
        if (fileUrl == null || fileUrl.isBlank()) {
            return;
        }

        try {
            // URL에서 파일 경로 추출: https://bucket.s3.../folder/filename.jpg → folder/filename.jpg
            String fileKey = fileUrl.substring(fileUrl.indexOf(".com/") + 5);
            amazonS3.deleteObject(bucketName, fileKey);
            System.out.println("✅ S3 파일 삭제 완료: " + fileKey);
        } catch (Exception e) {
            System.out.println("❌ S3 파일 삭제 실패: " + e.getMessage());
        }
    }

    private String getFileExtension(String fileName) {
        int dotIndex = fileName.lastIndexOf(".");
        return (dotIndex != -1) ? fileName.substring(dotIndex) : "";
    }
}