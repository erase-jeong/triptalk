package com.triptalker.triptalk.domain.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.triptalker.triptalk.domain.service.ApiService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
public class ApiController {

    private final ApiService apiService;

    @Operation(hidden = true)
    @GetMapping("/v1/get-theme-locations")
    public String getThemeLocations() {
        return apiService.getThemeLocationBasedList();
    }

    @Operation(hidden = true)
    @GetMapping("/v1/weather")
    public String getWeather() {
//        return apiService.getWeather();
        return null;
    }

    @Operation(hidden = true)
    @GetMapping("/v1/weather1")
    public String getWeatherV1() {
        return apiService.getWeatherV1();
    }

    @Operation(hidden = true)
    @GetMapping("/get-location")
    public String getLocation(@RequestParam String pageNum) {
        return apiService.getLocation(pageNum);
    }

    @Operation(hidden = true)
    @GetMapping("/get-vertex")
    public boolean getLocationVertex() throws JsonProcessingException {
        return apiService.getLocationVertex("1073", "2075");
    }

//    @GetMapping("/get-audio")
//    public String getLocationAudio() {
//        return apiService.getLocationAudio("1073", "2075");
//    }

}
