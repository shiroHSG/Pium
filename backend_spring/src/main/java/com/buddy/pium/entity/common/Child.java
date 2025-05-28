package com.buddy.pium.entity.common;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Table(name = "child")
public class Child {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long childId;

    @Column(length = 20, nullable = false)
    private String name;

    @Column(nullable = false)
    private LocalDate birth;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 1)
    private Enum.Gender gender;

    @Column(nullable = false)
    private Double height;

    @Column(nullable = false)
    private Double weight;

    private String profileImg;

    private String sensitiveInfo;

    @Builder.Default
    @OneToMany(mappedBy = "child", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MemberChild> memberLinks = new ArrayList<>();

    @Column(nullable = false, updatable = false)
    private java.sql.Timestamp createdAt;

    @Column(nullable = false)
    private java.sql.Timestamp updatedAt;

    @PrePersist
    protected void onCreate() {
        java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
        this.createdAt = now;
        this.updatedAt = now;
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = new java.sql.Timestamp(System.currentTimeMillis());
    }
}
