package com.triptalker.triptalk.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class LocationResDto {
    private Long locationId;
    private String locationName;
    private String address;
    private String themeCategory;
    private String imageUrl;
    private String weather;
    private String temperature;
    private boolean isBookmarked;
}
