package com.triptalker.triptalk.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class NearbyLocationResDto {
    private Long locationId;
    private String locationName;
    private String address;
    private String themeCategory;
    private String imageUrl;
    private String locationInfo;
    private boolean isAlarmMuted;
    private boolean isBookmarked;
}
