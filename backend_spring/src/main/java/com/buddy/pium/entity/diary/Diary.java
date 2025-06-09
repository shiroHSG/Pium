//package com.buddy.pium.entity.diary;
//
//import com.buddy.pium.entity.member.Member;
//import com.buddy.pium.entity.child.Child;
//import jakarta.persistence.*;
//import lombok.*;
//
//import java.time.LocalDateTime;
//
//@Entity
//@Getter @Setter
//@NoArgsConstructor @AllArgsConstructor @Builder
//public class Diary {
//
//        @Id
//    @GeneratedValue(strategy = GenerationType.IDENTITY)
//    private Long id;
//
//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "member_id", nullable = false)
//    private Member member;
//
//    @ManyToOne(fetch = FetchType.LAZY)
//    @JoinColumn(name = "child_id", nullable = false)
//    private Child child;
//
//    @Column(nullable = false, columnDefinition = "TEXT")
//    private String content;
//
//    @Column
//    private String imageUrl;
//
//    private LocalDateTime createdAt;
//
//    @PrePersist
//    public void setCreatedAt() {
//        this.createdAt = LocalDateTime.now();
//    }
//}
//}
//
