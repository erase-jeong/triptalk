package com.triptalker.triptalk.domain.dto;

import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;

@Getter @Setter
public class VisitHistoryDto {
    private Long locationId;
    private String imageUrl;
    private String locationName;
    private LocalDateTime visitedTime;
}
