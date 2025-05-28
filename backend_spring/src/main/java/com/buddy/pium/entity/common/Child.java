package com.buddy.pium.entity.common;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "member")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Member {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, unique = true, length = 50)
    private String email;

    @Column(nullable = false, length = 20)
    private String password;

    @Column(nullable = false, length = 20)
    private String name;

    @Column(nullable = false, unique = true, length = 20)
    private String nickname;

    @Column(nullable = false, unique = true, length = 20)
    private String phone;

    @Column(nullable = false)
    private String address;

    @Column(nullable = false)
    private LocalDate birth;

    @Column(nullable = false, length = 1)
    private String gender; // 'F', 'M'

    private String profileImg;

    private String mateInfo;

    @Column(nullable = false)
    private java.sql.Timestamp createAt;

    @Column(nullable = false)
    private java.sql.Timestamp updatedAt;
}
