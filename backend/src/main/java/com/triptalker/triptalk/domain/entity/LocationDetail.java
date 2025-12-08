package com.triptalker.triptalk.domain.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Entity
@Getter
@Setter
public class LocationDetail {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name="location_detail_id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "location_id")
    private Location location;

    private String stid;
    private String stlid;
    private String title;
    private String mapX;
    private String mapY;
    private String imageUrl;
    private String audioTitle;

    @Column(columnDefinition = "TEXT")
    private String script;

    private String playTime;
    private String audioUrl;
    private String langCode;
    private LocalDateTime createdAt = LocalDateTime.now();
    private LocalDateTime modifiedAt = LocalDateTime.now();


//    stid
//    stlid
//    title
//    addr1
//    addr2
//    map_x
//    map_y
//    image_url
//    information
//    audio_title
//    script
//    play_time
//    audio_url
//    created_at
//    modified_at
//    lang_code

}
