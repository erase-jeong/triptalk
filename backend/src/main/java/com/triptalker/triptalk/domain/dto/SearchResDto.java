package com.triptalker.triptalk.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
@AllArgsConstructor
public class SearchResDto {
    private Long locationId;
    private String tid;
    private String tlid;
    private String locationName;
    private String address;
    private String themeCategory;
}
