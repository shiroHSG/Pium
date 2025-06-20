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

    private final ShareService shareService;

    @Transactional
    public boolean toggleLike(Long shareId, Member member) {
        Share share = shareService.validateShareOwner(shareId, member);

        Optional<ShareLike> existing = shareLikeRepository.findByMemberAndShare(member, share);
        if (existing.isPresent()) {
            shareLikeRepository.delete(existing.get());
            return false;
        } else {
            ShareLike like = ShareLike.builder()
                    .member(member)
                    .share(share)
                    .build();
            shareLikeRepository.save(like);
            return true;
        }
    }

    public Long countLikes(Long shareId) {
        Share share = shareService.validateShare(shareId);
        return shareLikeRepository.countByShare(share);
    }


}
