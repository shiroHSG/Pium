package com.buddy.pium.entity.post;

import com.buddy.pium.entity.common.Member;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Post {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;
    private String content;
    private String category;
    private String imgUrl;

    private Long viewCount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")
    private Member member;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PostLike> likes = new ArrayList<>();

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PostComment> comments = new ArrayList<>();

    @CreationTimestamp
    private LocalDateTime createdAt;

    public boolean isLikedBy(Long memberId) {
        return likes.stream().anyMatch(like -> like.getMember().getId().equals(memberId));
    }

    // ---- 여기에 setter & 기타 메서드 추가 ----

    public void increaseViewCount() {
        this.viewCount = this.viewCount + 1;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public void setImgUrl(String imgUrl) {
        this.imgUrl = imgUrl;
    }
}
