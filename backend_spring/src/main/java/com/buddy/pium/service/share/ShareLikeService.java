package com.buddy.pium.service.share;

import com.buddy.pium.entity.common.Member;
import com.buddy.pium.entity.share.Share;
import com.buddy.pium.entity.share.ShareLike;
import com.buddy.pium.repository.common.MemberRepository;
import com.buddy.pium.repository.share.ShareLikeRepository;
import com.buddy.pium.repository.share.ShareRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ShareLikeService {

    private final ShareRepository shareRepository;
    private final MemberRepository memberRepository;
    private final ShareLikeRepository shareLikeRepository;

    @Transactional
    public boolean toggleLike(Long shareId, Long memberId) {
        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        Optional<ShareLike> existing = shareLikeRepository.findByMemberAndShare(member, share);
        if (existing.isPresent()) {
            shareLikeRepository.delete(existing.get());
//            share.setLikeCount(share.getLikeCount() - 1);
            return false;
        } else {
            ShareLike like = ShareLike.builder()
                    .member(member)
                    .share(share)
                    .build();
            shareLikeRepository.save(like);
//            share.setLikeCount(share.getLikeCount() + 1);
            return true;
        }
    }

    public Long getLikes(Long shareId, Long memberId) {
        Share share = shareRepository.findById(shareId)
                .orElseThrow(() -> new RuntimeException("게시글 없음"));
        Member member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원 없음"));

        return shareLikeRepository.countByShareAndMember(share, member);
    }

}
