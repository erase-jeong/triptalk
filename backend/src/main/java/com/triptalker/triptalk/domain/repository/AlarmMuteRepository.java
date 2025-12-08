package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.AlarmMute;
import com.triptalker.triptalk.domain.entity.Bookmark;
import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.entity.User;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface AlarmMuteRepository extends CrudRepository<AlarmMute, Long> {
    boolean existsByUserAndLocation(User user, Location location);
    List<AlarmMute> findByUserIdOrderByModifiedAtDesc(Long userId);
    Optional<AlarmMute> findByUserAndLocation(User user, Location location);
    boolean existsByLocationIdAndUserId(Long locationId, Long userId);
    void deleteByUser(User user);
}
