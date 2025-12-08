package com.triptalker.triptalk.domain.repository;


import com.triptalker.triptalk.domain.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface UserRepository extends JpaRepository<User, Long> {
    Boolean existsByUsername(String username);
    User findByUsername(String username);
    Optional<User> findByKakaoId(Long kakaoId);
}
