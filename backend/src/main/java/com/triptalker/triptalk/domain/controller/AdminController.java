package com.triptalker.triptalk.domain.controller;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import io.swagger.v3.oas.annotations.Operation;
//import okhttp3.*;
//import org.springframework.http.ResponseEntity;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.HashMap;
import java.util.Map;

@RestController
public class AdminController {

    @Operation(hidden = true)
    @GetMapping("/admin")
    public String admin() {
        return "admin controller";

    }

    @Operation(hidden = true)
    @GetMapping("/")
    public String home() throws JsonProcessingException {

//        String requestBody = "{\"startX\":126.92365493654832,\"startY\":37.556770374096615,\"angle\":20,\"speed\":30,\"endPoiId\":\"10001\",\"endX\":126.92432158129688,\"endY\":37.55279861528311,\"passList\":\"126.92774822,37.55395475_126.92577620,37.55337145\",\"reqCoordType\":\"WGS84GEO\",\"startName\":\"%EC%B6%9C%EB%B0%9C\",\"endName\":\"%EB%8F%84%EC%B0%A9\",\"searchOption\":\"0\",\"resCoordType\":\"WGS84GEO\",\"sort\":\"index\"}";

        Map<String, Object> requestBody = new HashMap<>();

        requestBody.put("startX", 129.01056);
        requestBody.put("startY", 35.097487);
        requestBody.put("endX", 129.007891);
        requestBody.put("endY", 35.096363);
        requestBody.put("startName", "출발지");
        requestBody.put("endName", "도착지");
        requestBody.put("passList", "129.01044,35.097974_129.010244,35.098204_129.010338,35.098681_129.00856,35.09775_129.007637,35.097598");
//        requestBody.put("reqCoordType", "WGS84GEO");


        ObjectMapper mapper = new ObjectMapper();
        String requestBodyJson = mapper.writeValueAsString(requestBody);

        WebClient webClient = WebClient.builder()
                .baseUrl("https://apis.openapi.sk.com")
                .build();

        return webClient.post()
                .uri("/tmap/routes/pedestrian?version=1&callback=function")
                .contentType(MediaType.APPLICATION_JSON)
                .accept(MediaType.APPLICATION_JSON)
                .header("appKey", "F17yKWxd2a2B3q75zCmny8lLhU6vWxWo65GfLTlx")
                .bodyValue(requestBodyJson)
                .retrieve()
                .bodyToMono(String.class)
                .block();
    }

}
