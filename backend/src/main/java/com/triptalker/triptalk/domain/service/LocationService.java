package com.triptalker.triptalk.domain.service;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.triptalker.triptalk.domain.dto.*;
import com.triptalker.triptalk.domain.entity.*;
import com.triptalker.triptalk.domain.repository.*;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Transactional(readOnly = true)
@Service
@RequiredArgsConstructor
public class LocationService {

    private final LocationRepository locationRepository;
    private final BookmarkRepository bookmarkRepository;
    private final AlarmMuteRepository alarmMuteRepository;
    private final VertexRepository vertexRepository;
    private final VisitHistoryRepository visitHistoryRepository;
    private final UserRepository userRepository;
    private final ApiService apiService;
    private final LocationDetailRepository locationDetailRepository;

    public List<SearchResDto> getSearch(String keyword) {
        List<Location> locations = locationRepository.findByLocationNameContaining(keyword);
        return locations.stream()  // 스트림 시작
                .map(location -> new SearchResDto(
                        location.getId(),
                        location.getTid(),
                        location.getTlid(),
                        location.getLocationName(),
                        location.getAddr1() + " " + location.getAddr2(),  // address 구성
                        location.getThemeCategory()
                ))
                .collect(Collectors.toList());  // 스트림을 List로 수집
    }

    public LocationResDto getLocations(String tid, String tlid, Long userId) {
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);
        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid + " and userId: " + userId);
        }
        Location location = locationOpt.get();



        boolean isBookmarked = bookmarkRepository.existsByLocationIdAndUserId(location.getId(), userId);

        return new LocationResDto(
                location.getId(),
                location.getLocationName(),
                location.getAddr1() + " " + location.getAddr2(),
                location.getThemeCategory(),
                location.getImageUrl(),
                apiService.getWeather(location.getMapY(), location.getMapX()).getWeather(),
                apiService.getWeather(location.getMapY(), location.getMapX()).getTemperature(),
                isBookmarked
        );
    }

    public NearbyLocationResDto getNearbyLocations(String tid, String tlid, Long userId) {
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);
        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid + " and userId: " + userId);
        }
        Location location = locationOpt.get();

        boolean isAlarmMuted = alarmMuteRepository.existsByLocationIdAndUserId(location.getId(), userId);
        boolean isBookmarked = bookmarkRepository.existsByLocationIdAndUserId(location.getId(), userId);

        return new NearbyLocationResDto(
                location.getId(),
                location.getLocationName(),
                location.getAddr1() + " " + location.getAddr2(),
                location.getThemeCategory(),
                location.getImageUrl(),
                location.getInformation(),
                isAlarmMuted,
                isBookmarked
        );
    }

    @Transactional
    public LocationDetailManualResDto getLocationAudioManual(String tid, String tlid, Long userId) {
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }
        Location location = locationOpt.get();

        setVisited(userId, location);

        List<LocationDetail> locationDetails = locationDetailRepository.findByLocation(location);
        log.info("locationDetails: {}", locationDetails);
        if (locationDetails.isEmpty()) {
            boolean isGetLocationAudio = apiService.getLocationAudio(tid, tlid);
            if (!isGetLocationAudio) {
                throw new RuntimeException("LocationDetail not found for location id: " + location.getId());
            }
            locationDetails = locationDetailRepository.findByLocation(location);
        }

        // LocationDetailResDto 생성 및 여러 LocationDetail 처리
        LocationDetailManualResDto locationDetailManualResDto = new LocationDetailManualResDto();
        locationDetailManualResDto.setLocationId(location.getId());
        locationDetailManualResDto.setLocationName(location.getLocationName());

        // 여러 LocationAudioResDto를 담기 위한 리스트 생성
        List<LocationDetailManualResDto.LocationAudioResDto> audioResDtoList = new ArrayList<>();

        for (LocationDetail locationDetail : locationDetails) {
            // LocationAudioResDto에 오디오 관련 정보 설정
            LocationDetailManualResDto.LocationAudioResDto audioResDto = new LocationDetailManualResDto.LocationAudioResDto();
            audioResDto.setLocationAudioId(locationDetail.getId());
            audioResDto.setStid(locationDetail.getStid());
            audioResDto.setStlid(locationDetail.getStlid());
            audioResDto.setTitle(locationDetail.getTitle());
            audioResDto.setMapX(locationDetail.getMapX());
            audioResDto.setMapY(locationDetail.getMapY());
            audioResDto.setImageUrl(locationDetail.getImageUrl());
            audioResDto.setAudioTitle(locationDetail.getAudioTitle());
            audioResDto.setScript(locationDetail.getScript());
            audioResDto.setPlayTime(locationDetail.getPlayTime());
            audioResDto.setAudioUrl(locationDetail.getAudioUrl());
            audioResDto.setLangCode(locationDetail.getLangCode());

            // 리스트에 추가
            audioResDtoList.add(audioResDto);
        }

        // LocationDetailResDto에 audioDetails 리스트 설정
        locationDetailManualResDto.setAudioDetails(audioResDtoList);

        return locationDetailManualResDto;

    }

    private void setVisited(Long userId, Location location) {
        Optional<User> userOpt = userRepository.findById(userId);
        if (!userOpt.isPresent()) {
            throw new RuntimeException("User not found for userId: " + userId);
        }
        User user = userOpt.get();

        Optional<VisitHistory> visitHistoryOpt = visitHistoryRepository.findByUserIdAndLocationId(userId, location.getId());
        VisitHistory visitHistory;

        if (visitHistoryOpt.isPresent()) {
            // 방문 기록이 이미 있으면, 기록을 최신화
            visitHistory = visitHistoryOpt.get();
            visitHistory.setModifiedAt(LocalDateTime.now()); // 수정 날짜를 최신화
        } else {
            // 방문 기록이 없으면, 새로운 기록 생성
            visitHistory = new VisitHistory();
            visitHistory.setUser(user);
            visitHistory.setLocation(location);
//            visitHistory.setStatus("visited");
            visitHistory.setCreatedAt(LocalDateTime.now());
            visitHistory.setModifiedAt(LocalDateTime.now());
        }

        visitHistoryRepository.save(visitHistory);
    }

    @Transactional
    public LocationDetailAutoResDto getLocationAudioAuto(String tid, String tlid, Long userId) throws JsonProcessingException {
        Optional<Location> locationOpt = locationRepository.findByTidAndTlid(tid, tlid);

        if (!locationOpt.isPresent()) {
            throw new RuntimeException("Location not found for tid: " + tid + " and tlid: " + tlid);
        }
        Location location = locationOpt.get();

        setVisited(userId, location);

        List<LocationDetail> locationDetails = locationDetailRepository.findByLocation(location);
        log.info("locationDetails: {}", locationDetails);
        if (locationDetails.isEmpty()) {
            boolean isGetLocationAudio = apiService.getLocationAudio(tid, tlid);
            if (!isGetLocationAudio) {
                throw new RuntimeException("LocationDetail not found for location id: " + location.getId());
            }
            locationDetails = locationDetailRepository.findByLocation(location);
        }

        List<Vertex> vertexes = vertexRepository.findByLocation(location);
        if (vertexes.isEmpty() && locationDetails.size() > 1) {
            boolean isGetLocationVertex = apiService.getLocationVertexV4(tid, tlid);
            if (!isGetLocationVertex) {
                throw new RuntimeException("vertexes not found for location id: " + location.getId());
            }
            vertexes = vertexRepository.findByLocation(location);
        }


        // LocationDetailResDto 생성 및 여러 LocationDetail 처리
        LocationDetailAutoResDto locationDetailAutoResDto = new LocationDetailAutoResDto();
        locationDetailAutoResDto.setLocationId(location.getId());
        locationDetailAutoResDto.setLocationName(location.getLocationName());

        // 여러 LocationAudioResDto를 담기 위한 리스트 생성
        List<LocationDetailAutoResDto.LocationAudioResDto> audioResDtoList = new ArrayList<>();
        List<LocationDetailAutoResDto.LocationVertexDto> vertexResList = new ArrayList<>();

        for (LocationDetail locationDetail : locationDetails) {
            // LocationAudioResDto에 오디오 관련 정보 설정
            LocationDetailAutoResDto.LocationAudioResDto audioResDto = new LocationDetailAutoResDto.LocationAudioResDto();
            audioResDto.setLocationAudioId(locationDetail.getId());
            audioResDto.setStid(locationDetail.getStid());
            audioResDto.setStlid(locationDetail.getStlid());
            audioResDto.setTitle(locationDetail.getTitle());
            audioResDto.setMapX(locationDetail.getMapX());
            audioResDto.setMapY(locationDetail.getMapY());
            audioResDto.setImageUrl(locationDetail.getImageUrl());
            audioResDto.setAudioTitle(locationDetail.getAudioTitle());
            audioResDto.setScript(locationDetail.getScript());
            audioResDto.setPlayTime(locationDetail.getPlayTime());
            audioResDto.setAudioUrl(locationDetail.getAudioUrl());
            audioResDto.setLangCode(locationDetail.getLangCode());

            // 리스트에 추가
            audioResDtoList.add(audioResDto);
        }

        for (Vertex vertex : vertexes) {
            LocationDetailAutoResDto.LocationVertexDto vertexDto = new LocationDetailAutoResDto.LocationVertexDto();
            vertexDto.setX(vertex.getX());
            vertexDto.setY(vertex.getY());

            vertexResList.add(vertexDto);
        }

        // LocationDetailResDto에 audioDetails 리스트 설정
        locationDetailAutoResDto.setAudioDetails(audioResDtoList);
        locationDetailAutoResDto.setVertexes(vertexResList);

        return locationDetailAutoResDto;

    }

}
