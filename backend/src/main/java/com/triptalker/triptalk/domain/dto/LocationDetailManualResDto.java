package com.triptalker.triptalk.domain.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter
@Setter
public class LocationDetailManualResDto {
    private Long locationId;
    private String locationName;
    private List<LocationAudioResDto> audioDetails = new ArrayList<>();

    @Getter @Setter
    public static class LocationAudioResDto {
        private Long locationAudioId;
        private String stid;
        private String stlid;
        private String title;
        private String mapX;
        private String mapY;
        private String imageUrl;
        private String audioTitle;
        private String script;
        private String playTime;
        private String audioUrl;
        private String langCode;
    }
}

