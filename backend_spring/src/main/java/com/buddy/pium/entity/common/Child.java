package com.buddy.pium.entity.common;

import com.buddy.pium.entity.diary.Diary;
import jakarta.persistence.*;
        import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@EntityListeners(AuditingEntityListener.class)
public class Child {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Column(length = 20, nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalDate birth;

    // M, F
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 1)
    private Enum.Gender gender;

    @Column(nullable = false)
    private Double height;

    @Column(nullable = false)
    private Double weight;

    private String profileImgUrl;

    private String sensitiveInfo;

    @Builder.Default
    @OneToMany(mappedBy = "child", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Diary> diaries = new ArrayList<>();

    @CreatedDate
    @Column(name = "created_at", nullable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(name = "updated_at", nullable = false)
    private LocalDateTime updatedAt;
}