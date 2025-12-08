package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.Location;
import org.springframework.data.repository.CrudRepository;

import java.util.List;
import java.util.Optional;

public interface LocationRepository extends CrudRepository<Location, Long> {
    Optional<Location> findByTidAndTlid(String tid, String tlid);
    List<Location> findByLocationNameContaining(String keyword);
}
