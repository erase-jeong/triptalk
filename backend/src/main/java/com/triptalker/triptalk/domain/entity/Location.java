package com.triptalker.triptalk.domain.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Getter
@Setter
public class Location {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="location_id")
    private Long id;

    private String tid;
    private String tlid;
    private String themeCategory;
    private String locationName;
    private String addr1;
    private String addr2;
    private double mapX;
    private double mapY;
    private String imageUrl;
    @Column(columnDefinition = "TEXT")
    private String information = "";
    private int distance;    // 네비게이션 api로 봤을 때의 총 거리
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime modifiedAt = LocalDateTime.now();

}
