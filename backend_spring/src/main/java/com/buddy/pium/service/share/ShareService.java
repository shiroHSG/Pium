package com.buddy.pium.service.share;

import com.buddy.pium.dto.share.ShareRequestDto;
import com.buddy.pium.dto.share.ShareResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import com.buddy.pium.service.FileUploadService;
import com.buddy.pium.util.AddressParser;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

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
        String imageUrl = null;
        if (image != null && !image.isEmpty()) {
            imageUrl = fileUploadService.upload(image, "shares");
        }
        Share share = Share.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .imageUrl(imageUrl)
                .member(member)
                .category(dto.getCategory())
                .viewCount(0L)
                .build();
        shareRepository.save(share);
    }

    public ShareResponseDto get(Long shareId) {
        Share share = validateShare(shareId);
        int likeCount = shareLikeRepository.countByShare(share).intValue();
        Member author = share.getMember();
        String[] addressTokens = AddressParser.parse(author.getAddress());
        return ShareResponseDto.from(
                share, likeCount,
                addressTokens[0], addressTokens[1], addressTokens[2]
        );
    }

    public List<ShareResponseDto> getAll() {
        return shareRepository.findAll().stream()
                .map(share -> {
                    int likeCount = shareLikeRepository.countByShare(share).intValue();
                    Member author = share.getMember();
                    String[] addressTokens = AddressParser.parse(author.getAddress());
                    return ShareResponseDto.from(
                            share, likeCount,
                            addressTokens[0], addressTokens[1], addressTokens[2]
                    );
                })
                .toList();
    }

    public List<ShareResponseDto> getByCategory(String category) {
        return shareRepository.findByCategory(category).stream()
                .map(share -> {
                    int likeCount = shareLikeRepository.countByShare(share).intValue();
                    Member author = share.getMember();
                    String[] addressTokens = AddressParser.parse(author.getAddress());
                    return ShareResponseDto.from(
                            share, likeCount,
                            addressTokens[0], addressTokens[1], addressTokens[2]
                    );
                })
                .toList();
    }

    // ✅ 글 수정(수정 후 반드시 save 호출)
    @Transactional
    public void updateShare(
            Long shareId,
            Member member,
            ShareRequestDto dto,
            MultipartFile image) {
        Share share = validateShareOwner(shareId, member);

        // 이미지가 새로 왔으면 기존 이미지 삭제 + 새 이미지 저장
        if (image != null && !image.isEmpty()) {
            if (share.getImageUrl() != null) {
                fileUploadService.delete(share.getImageUrl());
            }
            String imageUrl = fileUploadService.upload(image, "shares");
            share.setImageUrl(imageUrl);
        }

        // 제목/내용/카테고리 수정
        share.setTitle(dto.getTitle());
        share.setContent(dto.getContent());
        share.setCategory(dto.getCategory());

        // ⭐⭐ 실제로 DB에 반영하려면 save 호출!
        shareRepository.save(share);
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
