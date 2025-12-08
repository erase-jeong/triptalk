package com.triptalker.triptalk.domain.dto;

import lombok.Getter;
import lombok.Setter;

@Setter
@Getter
public class RegisterReqDto {
    private Long kakaoId;
    private String username;
    private String profileImage;
}
