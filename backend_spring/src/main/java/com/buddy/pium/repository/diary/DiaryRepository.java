package com.buddy.pium.repository.diary;

import com.buddy.pium.entity.diary.Diary;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface DiaryRepository extends JpaRepository<Diary, Long> {
    List<Diary> findByChildIdOrderByCreatedAtDesc(Long childId);
}
