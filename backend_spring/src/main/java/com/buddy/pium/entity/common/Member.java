package com.buddy.pium.entity.common;

import com.buddy.pium.entity.calender.Calender;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

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
@Table(name = "member")
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 50)
    private String username;

    @Column(nullable = false, unique = true, length = 50)
    private String nickname;

    @Column(nullable = false, unique = true, length = 100)
    private String email;

    @Column(nullable = false, length = 100)
    private String password;

    @Column(nullable = false, length = 15)
    private String phoneNumber;

    @Column(length = 100)
    private String address;

    @Column
    private LocalDate birth;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 1)
    private Enum.Gender gender;

    @Column
    private String profileImage;

    @Column
    private Long mateInfo;

    @CreatedDate
    @Column(nullable = false)
    private LocalDateTime createdAt;

    @LastModifiedDate
    @Column(nullable = false)
    private LocalDateTime updatedAt;

    @Column(length = 500)
    private String refreshToken;

    // ✅ 양방향 관계 설정
    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Child> children = new ArrayList<>();

    @OneToMany(mappedBy = "sender", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MateRequest> memberRequests = new ArrayList<>();

    @OneToMany(mappedBy = "receiver", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MateRequest> memberResponses = new ArrayList<>();

    @OneToMany(mappedBy = "member", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Calender> calenders = new ArrayList<>();

    // POST, 품앗이 동일하게 추가 할 것
    /*
    @OneToMany(mappedBy = "Entity에서 참조하는 변수명",
                            cascade = CascadeType.ALL,   : 000 기능을 한다
                            orphanRemoval = true)        : 역할을 담당한다.
    private List<Entity명> 임의의 변수명(ex. "calenders") = new ArrayList<>();
    */


}
