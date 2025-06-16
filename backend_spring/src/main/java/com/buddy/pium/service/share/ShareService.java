package com.buddy.pium.service.share;

import com.buddy.pium.dto.share.ShareRequestDto;
import com.buddy.pium.dto.share.ShareResponseDto;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ShareService {

    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final ShareLikeRepository shareLikeRepository;

    public void create(ShareRequestDto dto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Share share = Share.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .imgUrl(dto.getImgUrl())
                .member(member)
                .viewCount(0L)
//                .likeCount(0L)
                .build();

        shareRepository.save(share);
    }

    public ShareResponseDto get(Long id) {
        Share share = shareRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        share.setViewCount(share.getViewCount() + 1);
        shareRepository.save(share);

        return ShareResponseDto.from(share);
    }

    public List<ShareResponseDto> getAll() {
        return shareRepository.findAll().stream()
                .map(ShareResponseDto::from)
                .toList();
    }

    public void update(Long shareId, Long memberId, ShareRequestDto dto) {
        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!share.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        share.setTitle(dto.getTitle());
        share.setContent(dto.getContent());
        share.setImgUrl(dto.getImgUrl());
    }

    public void delete(Long shareId, Long memberId) {
        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!share.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        shareRepository.delete(share);
    }
}
