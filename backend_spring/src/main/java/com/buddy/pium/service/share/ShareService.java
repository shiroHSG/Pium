package com.buddy.pium.service.share;

import com.buddy.pium.dto.share.ShareRequestDto;
import com.buddy.pium.dto.share.ShareResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import com.buddy.pium.service.FileUploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ShareService {

    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final ShareLikeRepository shareLikeRepository;

    private final FileUploadService fileUploadService;

    @Transactional
    public void create(ShareRequestDto dto, Member member, MultipartFile image) {

        System.out.println("★ DTO로 받은 category = " + dto.getCategory());

        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "shares"); // 파일 저장 후 URL 리턴
        }

        Share share = Share.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrl(imageUrl)
                .member(member)
                .category(dto.getCategory())
                .viewCount(0L)
                .build();

        System.out.println("★ 저장 직전 share.category = " + share.getCategory());

        shareRepository.save(share);
    }

    public ShareResponseDto get(Long shareId) {
        Share share = validateShare(shareId);

        share.setViewCount(share.getViewCount() + 1);
        shareRepository.save(share);

        return ShareResponseDto.from(share);
    }

    public List<ShareResponseDto> getAll() {
        return shareRepository.findAll().stream()
                .map(ShareResponseDto::from)
                .toList();
    }

    public List<ShareResponseDto> getByCategory(String category) {
        return shareRepository.findByCategory(category).stream()
                .map(ShareResponseDto::from)
                .toList();
    }

    public void updateShare(
            Long shareId,
            Member member,
            ShareRequestDto dto,
            MultipartFile image) {
        Share share = validateShareOwner(shareId, member);

        if (image != null && !image.isEmpty()) {
            if (share.getImageUrl() != null) {
                fileUploadService.delete(share.getImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "shares");
            share.setImageUrl(imageUrl);
        }

        share.setTitle(dto.getTitle());
        share.setContent(dto.getContent());
        share.setCategory(dto.getCategory());
    }

    public void delete(Long shareId, Member member) {
        Share share = validateShareOwner(shareId, member);
        if (share.getImageUrl() != null) {
            fileUploadService.delete(share.getImageUrl());
        }
        shareRepository.delete(share);
    }

    public Share validateShareOwner(Long shareId, Member member) {
        Share share = validateShare(shareId);
        if (!share.getMember().equals(member)) {
            throw new AccessDeniedException("권한이 없습니다.");
        }
        return share;
    }
    public Share validateShare(Long shareId) {
        return shareRepository.findById(shareId)
                .orElseThrow(() -> new ResourceNotFoundException("글이 없습니다."));
    }
}
