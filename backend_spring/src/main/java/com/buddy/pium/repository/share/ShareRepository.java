package com.buddy.pium.repository.share;

import com.buddy.pium.entity.share.Share;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ShareRepository extends JpaRepository<Share, Long> {
    List<Share> findByCategory(String category);
}
