package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.entity.LocationDetail;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface LocationDetailRepository extends JpaRepository<LocationDetail, Long> {
    List<LocationDetail> findByLocation(Location location);
}
