package com.triptalker.triptalk.domain.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.triptalker.triptalk.domain.dto.*;
import com.triptalker.triptalk.domain.service.LocationService;
import com.triptalker.triptalk.domain.service.UserService;
import com.triptalker.triptalk.global.BaseResponse;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
public class LocationController {

    private final LocationService locationService;
    private final UserService userService;

    @Operation(summary = "관광지 검색 API")
    @GetMapping("/v1/search")
    public BaseResponse<List<SearchResDto>> getSearch(
            @RequestParam String keyword
    ) {
        List<SearchResDto> searches = locationService.getSearch(keyword);
        return new BaseResponse<>(searches);
    }

    @Operation(summary = "관광지 검색 후 나오는 관광 정보 API")
    @GetMapping("/v1/locations")
    public BaseResponse<LocationResDto> getLocationDetails(
            @RequestParam String tid,
            @RequestParam String tlid
    ) {
        Long userId = userService.getCurrentUserId();
        log.info("tid: {}, tlid: {}, userId: {}", tid, tlid, userId);

        return new BaseResponse<>(locationService.getLocations(tid, tlid, userId));
    }

    @Operation(summary = "근처 관광지 클릭 시 나오는 관광 정보 API")
    @GetMapping("/v1/nearby-locations")
    public BaseResponse<NearbyLocationResDto> getNearbyLocationDetails(
            @RequestParam String tid,
            @RequestParam String tlid
    ) {
        Long userId = userService.getCurrentUserId();
        log.info("tid: {}, tlid: {}, userId: {}", tid, tlid, userId);

        return new BaseResponse<>(locationService.getNearbyLocations(tid, tlid, userId));
    }

    @Operation(summary = "관광지 수동 가이드 API", description = "관광지 수동 가이드 버튼 누르면 나오는 오디오 가이드")
    @GetMapping("/v1/locations-audio/manual")
    public BaseResponse<LocationDetailManualResDto> getLocationAudioManual(
            @RequestParam String tid,
            @RequestParam String tlid
    ) {
        Long userId = userService.getCurrentUserId();
        log.info("tid: {}, tlid: {}, userId: {}", tid, tlid, userId);

        return new BaseResponse<>(locationService.getLocationAudioManual(tid, tlid, userId));
    }

    @Operation(summary = "관광지 자동 가이드 API", description = "관광지 자동 가이드 버튼 누르면 나오는 오디오 가이드 + 경로")
    @GetMapping("/v1/locations-audio/auto")
    public BaseResponse<LocationDetailAutoResDto> getLocationAudioAuto(
            @RequestParam String tid,
            @RequestParam String tlid
    ) throws JsonProcessingException {
        Long userId = userService.getCurrentUserId();
        log.info("tid: {}, tlid: {}, userId: {}", tid, tlid, userId);

        return new BaseResponse<>(locationService.getLocationAudioAuto(tid, tlid, userId));
    }


}
