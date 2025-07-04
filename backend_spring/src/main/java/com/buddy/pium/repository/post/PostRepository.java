package com.buddy.pium.repository.post;

import com.buddy.pium.entity.post.Post;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface PostRepository extends JpaRepository<Post, Long> {

    // 카테고리 단일 검색
    List<Post> findByCategory(String category);

    // 제목/내용 단일 검색
    List<Post> findByCategoryAndTitleContaining(String category, String keyword);
    List<Post> findByCategoryAndContentContaining(String category, String keyword);

    // 제목+내용 동시 검색 (카테고리 포함)
    @Query("SELECT p FROM Post p WHERE p.category = :category AND (p.title LIKE %:keyword% OR p.content LIKE %:keyword%)")
    List<Post> searchByCategoryAndTitleOrContent(@Param("category") String category, @Param("keyword") String keyword);

    // 전체(카테고리 없이) 제목/내용 검색
    List<Post> findByTitleContaining(String keyword);
    List<Post> findByContentContaining(String keyword);

    // 전체(카테고리 없이) 제목+내용 동시 검색
    @Query("SELECT p FROM Post p WHERE p.title LIKE %:keyword% OR p.content LIKE %:keyword%")
    List<Post> searchByTitleOrContent(@Param("keyword") String keyword);

    // 작성자(닉네임) 검색 (카테고리 포함/미포함)
    @Query("SELECT p FROM Post p WHERE p.category = :category AND p.member.nickname LIKE %:keyword%")
    List<Post> findByCategoryAndMemberNickname(@Param("category") String category, @Param("keyword") String keyword);

    @Query("SELECT p FROM Post p WHERE p.member.nickname LIKE %:keyword%")
    List<Post> findByMemberNickname(@Param("keyword") String keyword);

    @Query("SELECT p FROM Post p WHERE p.member.address LIKE %:keyword%")
    List<Post> findByMemberAddress(@Param("keyword") String keyword);

}
