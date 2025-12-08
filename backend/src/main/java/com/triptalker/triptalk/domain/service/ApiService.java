package com.triptalker.triptalk.domain.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.entity.LocationDetail;
import com.triptalker.triptalk.domain.entity.Vertex;
import com.triptalker.triptalk.domain.repository.LocationDetailRepository;
import com.triptalker.triptalk.domain.repository.LocationRepository;
import com.triptalker.triptalk.domain.repository.VertexRepository;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.DefaultUriBuilderFactory;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

@Slf4j
@Transactional(readOnly = true)
@Service
@RequiredArgsConstructor
public class ApiService {
    private final LocationRepository locationRepository;
    private final LocationDetailRepository locationDetailRepository;
    private final VertexRepository vertexRepository;

    @Value("${openapi.servicekey}")
    private String serviceKey;

    @Value("${kakao.apiKey}")
    private String KakaoApiKey;

//    @Value("${tmap.apiKey}")
//    private String TmapApiKey;

    @Transactional
    public String getThemeLocationBasedList() {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

        String url = "https://apis.data.go.kr/B551011/Odii/themeLocationBasedList"
                + "?numOfRows=200&pageNo=1"
                + "&MobileOS=AND"
                + "&MobileApp=TripTalk"
                + "&serviceKey=" + serviceKey
                + "&_type=json"
                + "&mapX=129.0105504845115"
                + "&mapY=35.0974835023459"
                + "&radius=1000"
                + "&langCode=ko";

        return WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)
                .block();  // 응답 바디를 String으로 변환
    }

    @Transactional
    public String getLocation(String pageNum) {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);


        String url = "https://apis.data.go.kr/B551011/Odii/themeBasedList"
                + "?numOfRows=100&pageNo=" + pageNum
                + "&MobileOS=AND"
                + "&MobileApp=TripTalk"
                + "&serviceKey=" + serviceKey
                + "&_type=json"
                + "&langCode=ko";

//            System.out.println(url);

        String json = WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(json); // JSON 문자열을 JsonNode로 파싱
            JsonNode itemNode = rootNode
                    .path("response") // "response" 노드로 이동
                    .path("body")     // "body" 노드로 이동
                    .path("items")    // "items" 노드로 이동
                    .path("item");

            if (itemNode.isArray()) {
                for (JsonNode item : itemNode) {
                    Location location = new Location();
                    location.setTid(item.path("tid").asText());
                    location.setTlid(item.path("tlid").asText());
                    location.setThemeCategory(item.path("themeCategory").asText());
                    location.setLocationName(item.path("title").asText());
                    location.setAddr1(item.path("addr1").asText());
                    location.setAddr2(item.path("addr2").asText());
                    location.setMapX(item.path("mapX").asDouble());
                    location.setMapY(item.path("mapY").asDouble());
                    location.setImageUrl(item.path("imageUrl").asText());
                    location.setCreatedAt(StringToLocalDateTime(item.path("createdtime").asText()));
                    location.setCreatedAt(StringToLocalDateTime(item.path("modifiedtime").asText()));

                    locationRepository.save(location);
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }


        return WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

    }

    @Transactional
    public boolean getLocationAudio(String tid, String tlid) {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);


        String url = "https://apis.data.go.kr/B551011/Odii/storyBasedList"
                + "?numOfRows=100&pageNo=1"
                + "&MobileOS=AND"
                + "&MobileApp=TripTalk"
                + "&serviceKey=" + serviceKey
                + "&_type=json"
                + "&langCode=ko"
                + "&tid=" + tid
                + "&tlid=" + tlid;

//            System.out.println(url);

        String json = WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(json); // JSON 문자열을 JsonNode로 파싱
            JsonNode itemNode = rootNode
                    .path("response") // "response" 노드로 이동
                    .path("body")     // "body" 노드로 이동
                    .path("items")    // "items" 노드로 이동
                    .path("item");

            if (itemNode.isArray()) {
                Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

                Location location;
                if (locationOpt.isPresent()) {
                    // If location exists, use it
                    location = locationOpt.get();
                    for (JsonNode item : itemNode) {
                        LocationDetail locationDetail = new LocationDetail();
                        locationDetail.setLocation(location); // Location과 연결
                        locationDetail.setStid(item.path("stid").asText());
                        locationDetail.setStlid(item.path("stlid").asText());
                        locationDetail.setTitle(item.path("title").asText());
                        locationDetail.setMapX(item.path("mapX").asText());
                        locationDetail.setMapY(item.path("mapY").asText());
                        locationDetail.setImageUrl(item.path("imageUrl").asText());
                        locationDetail.setAudioTitle(item.path("audioTitle").asText());
                        locationDetail.setScript(item.path("script").asText());
                        locationDetail.setPlayTime(item.path("playTime").asText());
                        locationDetail.setAudioUrl(item.path("audioUrl").asText());
                        locationDetail.setLangCode(item.path("langCode").asText());
                        locationDetail.setCreatedAt(StringToLocalDateTime(item.path("createdtime").asText()));
                        locationDetail.setCreatedAt(StringToLocalDateTime(item.path("modifiedtime").asText()));

                        locationDetailRepository.save(locationDetail);
                    }
                }

            }
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Transactional
    public String sendLocationToKakao(String tid, String tlid) throws JsonProcessingException {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);


        String url = "https://apis-navi.kakaomobility.com/v1/waypoints/directions";

        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }
        Location location = locationOpt.get();

        // Location에 해당하는 LocationDetails 가져오기
        List<LocationDetail> locationDetails = locationDetailRepository.findByLocation(location);

        if (locationDetails.isEmpty()) {
            throw new RuntimeException("LocationDetails not found for location id: " + location.getId());
        }

        // 출발지(origin): LocationDetails의 첫 번째
        LocationDetail originDetail = locationDetails.get(0);
        // 도착지(destination): LocationDetails의 마지막
        LocationDetail destinationDetail = locationDetails.get(locationDetails.size() - 1);

        // 경유지(waypoints): 첫 번째와 마지막을 제외한 나머지
        List<Map<String, Object>> waypoints = new ArrayList<>();
        for (int i = 1; i < locationDetails.size() - 1; i++) {
            LocationDetail waypointDetail = locationDetails.get(i);
            Map<String, Object> waypointMap = new HashMap<>();
            waypointMap.put("name", waypointDetail.getTitle());
            waypointMap.put("x", waypointDetail.getMapX());
            waypointMap.put("y", waypointDetail.getMapY());
            waypoints.add(waypointMap);
        }

        // 요청 본문(body) 생성
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("origin", createLocationMap(originDetail));
        requestBody.put("destination", createLocationMap(destinationDetail));
        requestBody.put("waypoints", waypoints);
        requestBody.put("priority", "RECOMMEND");
        requestBody.put("car_fuel", "GASOLINE");
        requestBody.put("car_hipass", false);
        requestBody.put("alternatives", false);
        requestBody.put("road_details", false);

        // JSON 변환
        ObjectMapper mapper = new ObjectMapper();
        String requestBodyJson = mapper.writeValueAsString(requestBody);
        log.info("requestBodyJson: " + requestBodyJson);

        // 카카오 API에 POST 요청 보내기
        String response = WebClient.builder()
                .build()
                .post()
                .uri("https://apis-navi.kakaomobility.com/v1/waypoints/directions")
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "KakaoAK " + KakaoApiKey)
                .bodyValue(requestBodyJson)
                .retrieve()
                .bodyToMono(String.class)
                .block();
        log.info("response kakao: {}", response);
        return response;
    }

    /**
     *
     * @param tid
     * @param tlid
     * @return
     * @throws JsonProcessingException
     * 수정 필요
     */
    @Transactional
    public String sendLocationToKakaoV2(String tid, String tlid) throws JsonProcessingException {
        log.info("sendLocationToKakaoV2 tid: " + tid + " tlid: " + tlid);
        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }
        Location location = locationOpt.get();

        // Location에 해당하는 LocationDetails 가져오기
        List<LocationDetail> locationDetails = locationDetailRepository.findByLocation(location);

        if (locationDetails.isEmpty()) {
            throw new RuntimeException("LocationDetails not found for location id: " + location.getId());
        }

        // 출발지(origin): LocationDetails의 첫 번째
        LocationDetail originDetail = locationDetails.get(0);
        // 도착지(destination): LocationDetails의 마지막
        LocationDetail destinationDetail = locationDetails.get(locationDetails.size() - 1);

        // 경유지(waypoints): 첫 번째와 마지막을 제외한 나머지
        List<Object> allResponses = new ArrayList<>();
        int waypointLimit = 30;

        // Loop through the waypoints in batches of up to 15
        for (int startIndex = 0; startIndex < locationDetails.size() - 1; startIndex += waypointLimit) {
            int endIndex = Math.min(startIndex + waypointLimit, locationDetails.size() - 1);

            LocationDetail currentBatchOrigin = locationDetails.get(startIndex);
            LocationDetail currentBatchDestination = locationDetails.get(endIndex);

            // 경유지(배치의 중간 값들) 설정: 첫 번째와 마지막 요소는 제외
            List<LocationDetail> waypointBatch;
            if (startIndex + 1 < endIndex) {
                waypointBatch = locationDetails.subList(startIndex + 1, endIndex);
            } else {
                waypointBatch = Collections.emptyList();  // 경유지가 없을 경우 빈 리스트
            }

            // 각 배치에 대해 처리
            JsonNode response = processBatch(waypointBatch, currentBatchOrigin, currentBatchDestination);
            allResponses.add(response);

        }

        // 응답 결과들을 합쳐서 반환
        return allResponses.toString();

//        ObjectMapper mapper = new ObjectMapper();
//        return mapper.writeValueAsString(allResponses);
    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public JsonNode processBatch(List<LocationDetail> waypointsBatch, LocationDetail originDetail, LocationDetail destinationDetail) throws JsonProcessingException {
        String url = "https://apis-navi.kakaomobility.com/v1/waypoints/directions";

        // 요청 본문(body) 생성
        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("origin", createLocationMap(originDetail));
        requestBody.put("destination", createLocationMap(destinationDetail));

        List<Map<String, Object>> waypoints = new ArrayList<>();
        for (LocationDetail waypoint : waypointsBatch) {
            Map<String, Object> waypointMap = new HashMap<>();
            waypointMap.put("name", waypoint.getTitle());
            waypointMap.put("x", waypoint.getMapX());
            waypointMap.put("y", waypoint.getMapY());
            waypoints.add(waypointMap);
        }

        requestBody.put("waypoints", waypoints);
        requestBody.put("priority", "RECOMMEND");
        requestBody.put("car_fuel", "GASOLINE");
        requestBody.put("car_hipass", false);
        requestBody.put("alternatives", false);
        requestBody.put("road_details", false);

        ObjectMapper mapper = new ObjectMapper();
        String requestBodyJson = mapper.writeValueAsString(requestBody);

        log.info("res: {}", requestBodyJson);
        // 카카오 API에 POST 요청 보내기
        String response = WebClient.builder()
                .build()
                .post()
                .uri(url)
                .contentType(MediaType.APPLICATION_JSON)
                .header("Authorization", "KakaoAK " + KakaoApiKey)
                .bodyValue(requestBodyJson)
                .retrieve()
                .bodyToMono(String.class)
                .block();
//        log.info("response: {}", response);

        return mapper.readTree(response);
    }

    private Map<String, Object> createLocationMap(LocationDetail locationDetail) {
        Map<String, Object> locationMap = new HashMap<>();
        locationMap.put("name", locationDetail.getTitle());
        locationMap.put("x", locationDetail.getMapX());
        locationMap.put("y", locationDetail.getMapY());
        return locationMap;
    }

    @Transactional
    public boolean getLocationVertex(String tid, String tlid) throws JsonProcessingException {

        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }

        Location location = locationOpt.get();

        // Location에 해당하는 Vertex가 있는지 확인
        List<Vertex> existingVertices = vertexRepository.findByLocation(location);

        // Vertex가 존재하면 더 이상 작업하지 않음
        if (!existingVertices.isEmpty()) {
            return true; // 이미 Vertex가 존재하므로 추가 작업 불필요
        }

        // Vertex가 비어 있으면 카카오 API 호출
        String json = sendLocationToKakao(tid, tlid);
        log.info("getLocationVertex : {}", json);
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(json);
            JsonNode routesNode = rootNode.path("routes");

            // 중복된 x, y 값을 저장하지 않기 위한 Set
            Set<String> uniqueVertices = new HashSet<>();

            if (routesNode.isArray()) {
                for (JsonNode route : routesNode) {
                    JsonNode sectionsNode = route.path("sections");
                    if (sectionsNode.isArray()) {
                        for (JsonNode section : sectionsNode) {
                            JsonNode roadsNode = section.path("roads");
                            if (roadsNode.isArray()) {
                                for (JsonNode road : roadsNode) {
                                    JsonNode vertexesNode = road.path("vertexes");

                                    // vertexes 안에 있는 x, y 좌표를 순회하면서 중복을 체크한 후 저장
                                    for (int i = 0; i < vertexesNode.size(); i += 2) {
                                        double x = vertexesNode.get(i).asDouble();
                                        double y = vertexesNode.get(i + 1).asDouble();

                                        String vertexKey = x + "," + y;  // 좌표를 String으로 변환하여 중복 체크

                                        // 중복된 좌표가 없을 경우에만 저장
                                        if (!uniqueVertices.contains(vertexKey)) {
                                            uniqueVertices.add(vertexKey);

                                            // Vertex 객체 생성 및 저장
                                            Vertex vertex = new Vertex();
                                            vertex.setLocation(location);
                                            vertex.setX(x);
                                            vertex.setY(y);
                                            vertexRepository.save(vertex);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    /**
     * @param tid
     * @param tlid
     * @return
     * @throws JsonProcessingException
     */
    @Transactional
    public boolean getLocationVertexV2(String tid, String tlid) throws JsonProcessingException {

        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }

        Location location = locationOpt.get();

        // Location에 해당하는 Vertex가 있는지 확인
        List<Vertex> existingVertices = vertexRepository.findByLocation(location);

        // Vertex가 존재하면 더 이상 작업하지 않음
        if (!existingVertices.isEmpty()) {
            return true; // 이미 Vertex가 존재하므로 추가 작업 불필요
        }

        // Vertex가 비어 있으면 카카오 API 호출
        String json = sendLocationToKakaoV2(tid, tlid);
        log.info("getLocationVertexV2 : {}", json);
        try {

            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootArray = mapper.readTree(json);

            for (JsonNode rootNode : rootArray) {
                JsonNode routesNode = rootNode.path("routes");

                // 중복된 x, y 값을 저장하지 않기 위한 Set
                Set<String> uniqueVertices = new HashSet<>();

                if (routesNode.isArray()) {
                    for (JsonNode route : routesNode) {
                        JsonNode sectionsNode = route.path("sections");
                        if (sectionsNode.isArray()) {
                            for (JsonNode section : sectionsNode) {
                                JsonNode roadsNode = section.path("roads");
                                if (roadsNode.isArray()) {
                                    for (JsonNode road : roadsNode) {
                                        JsonNode vertexesNode = road.path("vertexes");

                                        // vertexes 안에 있는 x, y 좌표를 순회하면서 중복을 체크한 후 저장
                                        for (int i = 0; i < vertexesNode.size(); i += 2) {
                                            double x = vertexesNode.get(i).asDouble();
                                            double y = vertexesNode.get(i + 1).asDouble();

                                            String vertexKey = x + "," + y;  // 좌표를 String으로 변환하여 중복 체크

                                            // 중복된 좌표가 없을 경우에만 저장
                                            if (!uniqueVertices.contains(vertexKey)) {
                                                uniqueVertices.add(vertexKey);

                                                // Vertex 객체 생성 및 저장
                                                Vertex vertex = new Vertex();
                                                vertex.setLocation(location);
                                                vertex.setX(x);
                                                vertex.setY(y);
                                                vertexRepository.save(vertex);
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }


            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    @Transactional
    public String sendLocationToTmap(String tid, String tlid) throws JsonProcessingException {
        log.info("sendLocationToTmap tid: " + tid + " tlid: " + tlid);
        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }
        Location location = locationOpt.get();

        // Location에 해당하는 LocationDetails 가져오기
        List<LocationDetail> locationDetails = locationDetailRepository.findByLocation(location);

        if (locationDetails.isEmpty()) {
            throw new RuntimeException("LocationDetails not found for location id: " + location.getId());
        }



        Map<String, Object> requestBody = new HashMap<>();

        // 출발지(origin): LocationDetails의 첫 번째
        LocationDetail originDetail = locationDetails.get(0);
        // 도착지(destination): LocationDetails의 마지막
        LocationDetail destinationDetail = locationDetails.get(locationDetails.size() - 1);

        // 경유지(waypoints): 첫 번째와 마지막을 제외한 나머지
        List<Object> allResponses = new ArrayList<>();
        int waypointLimit = 6;
        log.info("location end: {}", locationDetails.size() - 1);
        // Loop through the waypoints in batches of up to 15
        for (int startIndex = 0; startIndex < locationDetails.size() - 1; startIndex += waypointLimit) {
            int endIndex = Math.min(startIndex + waypointLimit, locationDetails.size() - 1);
            log.info("start: {}, end: {}", startIndex, endIndex);
            // 배치의 출발지: currentBatchOrigin, 도착지: currentBatchDestination
            LocationDetail currentBatchOrigin = locationDetails.get(startIndex);
            LocationDetail currentBatchDestination = locationDetails.get(endIndex);

            // 경유지(배치의 중간 값들) 설정: 첫 번째와 마지막 요소는 제외
            List<LocationDetail> waypointBatch;
            if (startIndex + 1 < endIndex) {
                waypointBatch = locationDetails.subList(startIndex + 1, endIndex);
            } else {
                waypointBatch = Collections.emptyList();  // 경유지가 없을 경우 빈 리스트
            }

            // 각 배치에 대해 출발지, 경유지, 도착지로 처리
            JsonNode response = processBatchTmap(waypointBatch, currentBatchOrigin, currentBatchDestination);
            allResponses.add(response);

        }

        // 응답 결과들을 합쳐서 반환
        return allResponses.toString();

//        ObjectMapper mapper = new ObjectMapper();
//        return mapper.writeValueAsString(allResponses);

    }

    @Transactional(propagation = Propagation.REQUIRES_NEW)
    public JsonNode processBatchTmap(List<LocationDetail> waypoints, LocationDetail originDetail, LocationDetail destinationDetail) throws JsonProcessingException {
        String url = "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1";

        Map<String, Object> requestBody = new HashMap<>();

        requestBody.put("startX", Double.parseDouble(originDetail.getMapX()));
        requestBody.put("startY", Double.parseDouble(originDetail.getMapY()));
        requestBody.put("endX", Double.parseDouble(destinationDetail.getMapX()));
        requestBody.put("endY", Double.parseDouble(destinationDetail.getMapY()));
        requestBody.put("startName", "출발지");
        requestBody.put("endName", "도착지");
//        requestBody.put("reqCoordType", "WGS84GEO");

        // passList 생성 (경유지 좌표를 `_`로 구분)
        StringBuilder passListBuilder = new StringBuilder();
        for (LocationDetail waypoint : waypoints) {
            passListBuilder.append(waypoint.getMapX())
                    .append(",")
                    .append(waypoint.getMapY())
                    .append("_");
        }
        // 마지막 _ 제거
        log.info("waypoints: {}", passListBuilder.toString());
        if (waypoints.size() > 0) {
            String passList = passListBuilder.substring(0, passListBuilder.length() - 1);
            requestBody.put("passList", passList);
        }

        ObjectMapper mapper = new ObjectMapper();
        String requestBodyJson = mapper.writeValueAsString(requestBody);

        log.info("res: {}", requestBodyJson);



        WebClient webClient = WebClient.builder()
                .baseUrl("https://apis.openapi.sk.com")
                .build();
        String response = webClient.post()
                .uri("/tmap/routes/pedestrian?version=1&callback=function")
                .accept(MediaType.APPLICATION_JSON)
                .contentType(MediaType.APPLICATION_JSON)
                .header("appKey", "F17yKWxd2a2B3q75zCmny8lLhU6vWxWo65GfLTlx")  // appKey가 요청에 포함됨
                .bodyValue(requestBodyJson)
                .retrieve()
                .bodyToMono(String.class)
                .block();

        return mapper.readTree(response);
    }

    @Transactional
    public boolean getLocationVertexV3(String tid, String tlid) throws JsonProcessingException {

        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }

        Location location = locationOpt.get();

        // Location에 해당하는 Vertex가 있는지 확인
        List<Vertex> existingVertices = vertexRepository.findByLocation(location);

        // Vertex가 존재하면 더 이상 작업하지 않음
        if (!existingVertices.isEmpty()) {
            return true; // 이미 Vertex가 존재하므로 추가 작업 불필요
        }

        // Vertex가 비어 있으면 카카오 API 호출
        String json = sendLocationToTmap(tid, tlid);
        log.info("getLocationVertexV3 : {}", json);
        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootArray = mapper.readTree(json);

            for (JsonNode rootNode : rootArray) {
                JsonNode featuresNode = rootNode.path("features");
                log.info("features: {}", featuresNode);
                // 중복된 좌표를 저장하지 않기 위한 Set
                Set<String> uniqueVertices = new HashSet<>();

                if (featuresNode.isArray()) {
                    for (JsonNode feature : featuresNode) {
                        JsonNode geometryNode = feature.path("geometry");
                        if (geometryNode != null && geometryNode.path("coordinates").isArray()) {
                            JsonNode coordinatesNode = geometryNode.path("coordinates");

                            // 좌표가 LineString인지 Point인지에 따라 처리
                            if (geometryNode.path("type").asText().equals("LineString")) {
                                for (JsonNode coord : coordinatesNode) {
                                    double x = coord.get(0).asDouble();
                                    double y = coord.get(1).asDouble();

                                    String vertexKey = x + "," + y;  // 중복 방지용 key
                                    if (!uniqueVertices.contains(vertexKey)) {
                                        uniqueVertices.add(vertexKey);
                                        log.info("x : {}, y : {}", x, y);
                                        // Vertex 객체 생성 및 저장
                                        Vertex vertex = new Vertex();
                                        vertex.setLocation(location);
                                        vertex.setX(x);
                                        vertex.setY(y);
                                        vertexRepository.save(vertex);
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return true;
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }


    @Transactional
    public boolean getLocationVertexV4(String tid, String tlid) throws JsonProcessingException {

        // tid, tlid에 해당하는 Location 검색
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }

        Location location = locationOpt.get();

        // Location에 해당하는 Vertex가 있는지 확인
        List<Vertex> existingVertices = vertexRepository.findByLocation(location);

        // Vertex가 존재하면 더 이상 작업하지 않음
        if (!existingVertices.isEmpty()) {
            return true; // 이미 Vertex가 존재하므로 추가 작업 불필요
        }

        String json = null;
        boolean isTmapSuccessful = false;

        try {
            // Tmap API 호출
            json = sendLocationToTmap(tid, tlid);
            log.info("Tmap API 호출 성공: {}", json);
            isTmapSuccessful = true;
        } catch (Exception e) {
            // Tmap API 호출 실패 시 예외 처리
            log.error("Tmap API 호출 실패. 카카오 API 호출로 전환합니다: {}", e.getMessage());
        }

        if (!isTmapSuccessful) {
            // Tmap API가 실패한 경우 카카오맵 API 호출
            json = sendLocationToKakaoV2(tid, tlid);
            log.info("카카오맵 API 호출 성공: {}", json);
        }

        return processVertexData(json, location, isTmapSuccessful);
    }

    private boolean processVertexData(String json, Location location, boolean isTmap) throws JsonProcessingException {
        ObjectMapper mapper = new ObjectMapper();
        try {
            JsonNode rootArray = mapper.readTree(json);

            Set<String> uniqueVertices = new HashSet<>();

            if (isTmap) {
                // Tmap API 응답 처리
                for (JsonNode rootNode : rootArray) {
                    JsonNode featuresNode = rootNode.path("features");
                    if (featuresNode.isArray()) {
                        for (JsonNode feature : featuresNode) {
                            JsonNode geometryNode = feature.path("geometry");
                            if (geometryNode != null && geometryNode.path("coordinates").isArray()) {
                                JsonNode coordinatesNode = geometryNode.path("coordinates");

                                // 좌표가 LineString인지 Point인지에 따라 처리
                                if (geometryNode.path("type").asText().equals("LineString")) {
                                    for (JsonNode coord : coordinatesNode) {
                                        double x = coord.get(0).asDouble();
                                        double y = coord.get(1).asDouble();
                                        String vertexKey = x + "," + y;
                                        if (!uniqueVertices.contains(vertexKey)) {
                                            uniqueVertices.add(vertexKey);
                                            saveVertex(location, x, y);
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                // 카카오맵 API 응답 처리
                for (JsonNode rootNode : rootArray) {
                    JsonNode routesNode = rootNode.path("routes");
                    if (routesNode.isArray()) {
                        for (JsonNode route : routesNode) {
                            JsonNode sectionsNode = route.path("sections");
                            if (sectionsNode.isArray()) {
                                for (JsonNode section : sectionsNode) {
                                    JsonNode roadsNode = section.path("roads");
                                    if (roadsNode.isArray()) {
                                        for (JsonNode road : roadsNode) {
                                            JsonNode vertexesNode = road.path("vertexes");
                                            for (int i = 0; i < vertexesNode.size(); i += 2) {
                                                double x = vertexesNode.get(i).asDouble();
                                                double y = vertexesNode.get(i + 1).asDouble();
                                                String vertexKey = x + "," + y;
                                                if (!uniqueVertices.contains(vertexKey)) {
                                                    uniqueVertices.add(vertexKey);
                                                    saveVertex(location, x, y);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            return true;
        } catch (Exception e) {
            log.error("Vertex 데이터 처리 중 오류 발생: {}", e.getMessage());
            return false;
        }
    }

    private void saveVertex(Location location, double x, double y) {
        Vertex vertex = new Vertex();
        vertex.setLocation(location);
        vertex.setX(x);
        vertex.setY(y);
        vertexRepository.save(vertex);
    }

    private LocalDateTime StringToLocalDateTime(String time) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
        return LocalDateTime.parse(time, formatter);
    }

    @Transactional
    public String getWeatherV1() {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);


        String url = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
                + "?numOfRows=100&pageNo=1"
                + "&serviceKey=" + serviceKey
                + "&dataType=JSON"
                + "&base_date=20240930&base_time=0000&nx=37&ny=126";

        log.info("url : {}", url);

        String json = WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(json); // JSON 문자열을 JsonNode로 파싱
            JsonNode itemNode = rootNode
                    .path("response") // "response" 노드로 이동
                    .path("body")     // "body" 노드로 이동
                    .path("items")    // "items" 노드로 이동
                    .path("item");

            if (itemNode.isArray()) {
                for (JsonNode item : itemNode) {

                }
            }

        } catch (Exception e) {
            e.printStackTrace();
        }


        return WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

    }

    @Transactional
    public WeatherResult getWeather(double nx, double ny) {

        DefaultUriBuilderFactory factory = new DefaultUriBuilderFactory();
        factory.setEncodingMode(DefaultUriBuilderFactory.EncodingMode.NONE);

        String baseDate = getFormattedDateTime().getFormattedDate();
        String baseTime = getFormattedDateTime().getFormattedTime();
        String getNx = Integer.toString((int) Math.round(nx));
        String getNy = Integer.toString((int) Math.round(ny));
        String strnx = "37";
        String strny = "126";

        String weatherDescription = "";
        String temperature = "";
//        log.info("nx: {}, ny: {}", getNx, getNy);
//        log.info("baseDate: {}", baseDate);
//        log.info("baseTime: {}", baseTime);

        String url = "https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0/getUltraSrtFcst"
                + "?numOfRows=100&pageNo=1"
                + "&serviceKey=" + serviceKey
                + "&dataType=JSON"
                + "&base_date=" + baseDate
                + "&base_time=" + baseTime
                + "&nx=" + getNx + "&ny=" + getNy;

//        log.info("url : {}", url);

        String json = WebClient.builder()
                .uriBuilderFactory(factory)
                .build()
                .get()
                .uri(url)              // 전체 URL 사용
                .retrieve()            // 응답을 받아옴
                .bodyToMono(String.class)  // 응답 바디를 String으로 변환
                .block();

        try {
            ObjectMapper mapper = new ObjectMapper();
            JsonNode rootNode = mapper.readTree(json); // JSON 문자열을 JsonNode로 파싱
            JsonNode itemNode = rootNode
                    .path("response") // "response" 노드로 이동
                    .path("body")     // "body" 노드로 이동
                    .path("items")    // "items" 노드로 이동
                    .path("item");

            if (itemNode.isArray()) {
                // 관심 있는 카테고리만 필터링
                List<String> targetCategories = Arrays.asList("T1H", "SKY", "PTY");
                Map<String, JsonNode> firstItemsByCategory = new HashMap<>();

                // 각 카테고리의 첫 번째 아이템만 저장
                for (JsonNode item : itemNode) {
                    String category = item.path("category").asText();
                    // 대상 카테고리에 해당하고, 첫 번째 아이템이 저장되어 있지 않은 경우에만 저장
                    if (targetCategories.contains(category)) {
                        firstItemsByCategory.putIfAbsent(category, item);
                    }
                }

                // 첫 번째 아이템만 수집된 결과를 출력 또는 사용
//                for (JsonNode firstItem : firstItemsByCategory.values()) {
//                    System.out.println(firstItem.toString());
//                }


                // PTY 값 처리
                if (firstItemsByCategory.containsKey("PTY")) {
                    String ptyValue = firstItemsByCategory.get("PTY").path("fcstValue").asText();
                    switch (ptyValue) {
                        case "1":
                            weatherDescription = "비";
                            break;
                        case "2":
                            weatherDescription = "비/눈";
                            break;
                        case "3":
                            weatherDescription = "눈";
                            break;
                        case "5":
                            weatherDescription = "빗방울";
                            break;
                        case "6":
                            weatherDescription = "빗방울눈날림";
                            break;
                        case "7":
                            weatherDescription = "눈날림";
                            break;
                        default:
                            weatherDescription = ""; // PTY가 0일 경우 이후 SKY 확인
                            break;
                    }
                }

                // PTY가 0인 경우 SKY 값 처리
                if (weatherDescription.isEmpty() && firstItemsByCategory.containsKey("SKY")) {
                    String skyValue = firstItemsByCategory.get("SKY").path("fcstValue").asText();
                    switch (skyValue) {
                        case "1":
                            weatherDescription = "맑음";
                            break;
                        case "3":
                            weatherDescription = "구름많음";
                            break;
                        case "4":
                            weatherDescription = "흐림";
                            break;
                        default:
                            weatherDescription = "알 수 없음";
                            break;
                    }
                }
                temperature = firstItemsByCategory.get("T1H").path("fcstValue").asText();
                // 최종 결과 출력
//                System.out.println("현재 날씨: " + weatherDescription);
//                System.out.println("현재 기온: " + temperature);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

//        log.info("weather: {}, temp: {}", weatherDescription, temperature);
        return new WeatherResult(weatherDescription, temperature);

    }

    private DateTimeResult getFormattedDateTime() {
        LocalDateTime now = LocalDateTime.now();

        if (now.getMinute() > 45) {
            now = now.withMinute(30);
        } else {
            now = now.minusHours(1).withMinute(30);

            // 시간이 0시인 경우 전날의 23시로 설정
            if (now.getHour() == -1) {
                now = now.minusDays(1).withHour(23).withMinute(30);
            }
        }

        // 날짜와 시간 포맷팅
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyyMMdd");
        DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HHmm");

        String formattedDate = now.format(dateFormatter);
        String formattedTime = now.format(timeFormatter);

        // 출력
//        System.out.println("날짜: " + formattedDate);
//        System.out.println("시간: " + formattedTime);
        return new DateTimeResult(formattedDate, formattedTime);
    }

    @Data
    @AllArgsConstructor
    class DateTimeResult {
        private String formattedDate;
        private String formattedTime;
    }

    @Data
    @AllArgsConstructor
    class WeatherResult {
        private String weather;
        private String temperature;
    }
}
