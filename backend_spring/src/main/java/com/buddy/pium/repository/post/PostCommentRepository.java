package com.buddy.pium.repository.post;

import com.buddy.pium.entity.post.Post;
import com.buddy.pium.entity.post.PostComment;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface PostCommentRepository extends JpaRepository<PostComment, Long> {
    List<PostComment> findByPost(Post post);
}
