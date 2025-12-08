package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.Bookmark;
import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.entity.User;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface BookmarkRepository extends CrudRepository<Bookmark, Long> {
    boolean existsByLocationIdAndUserId(Long locationId, Long userId);
    List<Bookmark> findByUserIdOrderByModifiedAtDesc(Long userId);
    Optional<Bookmark> findByUserAndLocation(User user, Location location);
    boolean existsByUserAndLocation(User user, Location location);
    void deleteByUser(User user);
    List<Bookmark> findTop7ByOrderByModifiedAtDesc();
}
