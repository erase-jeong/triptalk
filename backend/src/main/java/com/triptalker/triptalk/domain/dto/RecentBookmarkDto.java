package com.triptalker.triptalk.domain.dto;

import lombok.Getter;
import lombok.Setter;


@Getter
@Setter
public class RecentBookmarkDto {
    private Long locationId;
    private String tid;
    private String tlid;
    private String locationName;
    private String imageUrl;
}
