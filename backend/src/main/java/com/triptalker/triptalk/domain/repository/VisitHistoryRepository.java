package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.User;
import com.triptalker.triptalk.domain.entity.VisitHistory;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface VisitHistoryRepository extends CrudRepository<VisitHistory, Long> {
    Optional<VisitHistory> findByUserIdAndLocationId(Long userId, Long locationId);
    List<VisitHistory> findByUserIdOrderByModifiedAtDesc(Long userId);
    void deleteByUser(User user);
}
