package com.triptalker.triptalk.domain.dto;

import lombok.Getter;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

@Getter @Setter
public class MypageResDto {
    private ProfileDto profile = new ProfileDto();
    private List<String> visitHistories = new ArrayList<>();
    private List<String> bookmarks = new ArrayList<>();

    @Getter @Setter
    public static class ProfileDto {
        private String username;
        private String profileImage;
    }

}
