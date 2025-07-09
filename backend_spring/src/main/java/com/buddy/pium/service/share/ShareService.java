package com.buddy.pium.service.share;

import com.buddy.pium.dto.share.ShareListItemDto;
import com.buddy.pium.dto.share.ShareRequestDto;
import com.buddy.pium.dto.share.ShareResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.entity.share.ShareLike;
import com.buddy.pium.exception.ResourceNotFoundException;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import com.buddy.pium.service.FileUploadService;
import com.buddy.pium.util.AddressParser;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ShareService {

    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final ShareLikeRepository shareLikeRepository;
    private final FileUploadService fileUploadService;

    // ========== [추가] 내가 쓴 나눔글(목록) ==========
    public Page<ShareListItemDto> findMyShares(Member member, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<Share> shares = shareRepository.findByMemberOrderByCreatedAtDesc(member, pageable);
        return shares.map(ShareListItemDto::fromEntity);
    }

    // ========== [추가] 내가 좋아요 누른 나눔글(목록) ==========
    public Page<ShareListItemDto> findLikedShares(Member member, int page, int size) {
        // 1. 내가 누른 좋아요 ShareLike 엔티티 전체 추출 (최신순)
        List<ShareLike> likes = shareLikeRepository.findByMemberOrderByIdDesc(member);

        // 2. shareId 리스트만 추출 (중복/Null 체크 포함)
        List<Long> shareIds = likes.stream()
                .map(like -> like.getShare().getId())
                .distinct()
                .collect(Collectors.toList());

        if (shareIds.isEmpty()) {
            // 아무것도 없으면 빈 Page 반환
            return Page.empty(PageRequest.of(page, size));
        }

        // 3. 해당 Share id로 페이징 + 최신순 조회
        Pageable pageable = PageRequest.of(page, size);
        Page<Share> shares = shareRepository.findByIdInOrderByCreatedAtDesc(shareIds, pageable);
        return shares.map(ShareListItemDto::fromEntity);
    }

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

    // ⭐ 조회수 증가 로직 추가
    @Transactional
    public ShareResponseDto get(Long shareId) {
        Share share = validateShare(shareId);

        // 조회수 증가
        share.setViewCount(share.getViewCount() + 1);
        shareRepository.save(share);

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

    @Transactional
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

    // 🔎 통합 검색 기능
    public List<ShareResponseDto> searchShares(String keyword) {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAll();
        }
        List<Share> shares = shareRepository.searchByKeyword(keyword.trim());
        return shares.stream()
                .map(share -> {
                    int likeCount = shareLikeRepository.countByShare(share).intValue();
                    Member author = share.getMember();
                    String[] addressTokens = AddressParser.parse(author.getAddress());
                    return ShareResponseDto.from(
                            share, likeCount,
                            addressTokens[0], addressTokens[1], addressTokens[2]
                    );
                })
                .collect(Collectors.toList());
    }
}
