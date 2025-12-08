package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.entity.Vertex;
import org.springframework.data.repository.CrudRepository;

import java.util.List;

public interface VertexRepository extends CrudRepository<Vertex, Long> {
    List<Vertex> findByLocation(Location location);
}
