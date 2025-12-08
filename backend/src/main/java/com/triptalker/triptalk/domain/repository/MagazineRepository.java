package com.triptalker.triptalk.domain.repository;

import com.triptalker.triptalk.domain.entity.Magazine;
import org.springframework.data.repository.CrudRepository;

public interface MagazineRepository extends CrudRepository<Magazine, Long> {
}
