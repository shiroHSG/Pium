package com.buddy.pium.service.share;

import com.buddy.pium.dto.share.ShareRequest;
import com.buddy.pium.dto.share.ShareResponse;
import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.entity.share.ShareLike;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ShareService {

    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final ShareLikeRepository shareLikeRepository;

    public void create(ShareRequest dto, Long memberId) {
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Share share = Share.builder()
                .title(dto.getTitle())
                .content(dto.getContent())
                .postImg(dto.getPostImg())
                .member(member)
                .viewCount(0L)
//                .likeCount(0L)
                .build();

        shareRepository.save(share);
    }

    public ShareResponse get(Long id) {
        Share share = shareRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        share.setViewCount(share.getViewCount() + 1);
        shareRepository.save(share);

        return ShareResponse.from(share);
    }

    public List<ShareResponse> getAll() {
        return shareRepository.findAll().stream()
                .map(ShareResponse::from)
                .toList();
    }

    public void update(Long shareId, Long memberId, ShareRequest dto) {
        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("글 없음"));

        if (!share.getMember().getId().equals(memberId)) {
            throw new RuntimeException("권한 없음");
        }

        share.setTitle(dto.getTitle());
        share.setContent(dto.getContent());
        share.setPostImg(dto.getPostImg());
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
