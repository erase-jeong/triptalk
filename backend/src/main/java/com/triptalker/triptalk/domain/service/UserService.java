package com.triptalker.triptalk.domain.service;

import com.triptalker.triptalk.domain.dto.*;
import com.triptalker.triptalk.domain.entity.*;
import com.triptalker.triptalk.domain.repository.*;
import com.triptalker.triptalk.global.jwt.JWTFilter;
import com.triptalker.triptalk.global.jwt.JWTUtil;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Slf4j
@Service
@Transactional(readOnly = true)
@RequiredArgsConstructor
public class UserService {

    private final UserRepository userRepository;
    private final LocationRepository locationRepository;
    private final BookmarkRepository bookmarkRepository;
    private final VisitHistoryRepository visitHistoryRepository;
    private final AlarmMuteRepository alarmMuteRepository;
    private final JWTUtil jwtUtil;


    public void joinProcess(JoinDto joinDto) {

        String username = joinDto.getUsername();
        String password = joinDto.getPassword();

        Boolean isExist = userRepository.existsByUsername(username);

        if (isExist) {

            return;
        }

        User data = new User();

        data.setUsername(username);
        data.setRole("ROLE_ADMIN");

        userRepository.save(data);

    }

    public List<RecentBookmarkDto> getRecentBookmarks() {
        // 북마크 목록을 가져와 RecentBookmarkDto로 변환
        return bookmarkRepository.findTop7ByOrderByModifiedAtDesc().stream()
                .map(this::convertToDto) // 엔티티를 DTO로 변환
                .collect(Collectors.toList());
    }

    // Bookmark 엔티티를 RecentBookmarkDto로 변환하는 메서드
    private RecentBookmarkDto convertToDto(Bookmark bookmark) {
        RecentBookmarkDto dto = new RecentBookmarkDto();
        dto.setLocationId(bookmark.getLocation().getId());
        dto.setTid(bookmark.getLocation().getTid()); // Location 엔티티에서 tid 가져오기
        dto.setTlid(bookmark.getLocation().getTlid()); // Location 엔티티에서 tlid 가져오기
        dto.setLocationName(bookmark.getLocation().getLocationName());
        dto.setImageUrl(bookmark.getLocation().getImageUrl());
        return dto;
    }

    @Transactional
    public String kakaoRegister(RegisterReqDto registerReqDto) {
        String username = registerReqDto.getUsername();
        String profileImage = registerReqDto.getProfileImage();
        Long kakaoId = registerReqDto.getKakaoId();

        Optional<User> existingUser = userRepository.findByKakaoId(kakaoId);
        User user;

        if (existingUser.isPresent()) {
            // 이미 존재하는 유저가 있으면 해당 유저 객체를 사용하여 수정
            user = existingUser.get();
            user.setUsername(username);
            user.setProfileImageUrl(profileImage);
            user.setModifiedAt(LocalDateTime.now());
            user.setRole("ROLE_USER");
        } else {
            // 존재하지 않으면 새로운 유저를 생성
            user = new User();
            user.setUsername(username);
            user.setKakaoId(kakaoId);
            user.setProfileImageUrl(profileImage);
            user.setModifiedAt(LocalDateTime.now());
            user.setRole("ROLE_USER");
        }

        userRepository.save(user);

        Long userId = user.getId();

        log.info("service: {}", userId);
        String token = jwtUtil.createJwt(userId, "ROLE_USER", 1000*60*60*24*365L);
        return token;


    }

    public Long getCurrentUserId() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication != null && authentication.getPrincipal() instanceof CustomUserDetails) {
            CustomUserDetails userDetails = (CustomUserDetails) authentication.getPrincipal();
            return userDetails.getId();
        }
        return null; // 또는 예외를 던질 수 있음
    }

    public MypageResDto getMypage(Long userId) {
        // 1. 유저 정보 가져오기
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        List<VisitHistory> visitHistories = visitHistoryRepository.findByUserIdOrderByModifiedAtDesc(userId);
        List<Bookmark> bookmarks = bookmarkRepository.findByUserIdOrderByModifiedAtDesc(userId);

        MypageResDto mypageResDto = new MypageResDto();

        // 프로필 정보 설정
        MypageResDto.ProfileDto profileDto = new MypageResDto.ProfileDto();
        profileDto.setUsername(user.getUsername());
        profileDto.setProfileImage(user.getProfileImageUrl());

        mypageResDto.setProfile(profileDto);

        // 방문 기록 설정
        mypageResDto.setVisitHistories(
                visitHistories.stream()
                        .map(visit -> visit.getLocation().getImageUrl())
                        .collect(Collectors.toList())
        );

        // 북마크 설정
        mypageResDto.setBookmarks(
                bookmarks.stream()
                        .map(bookmark -> bookmark.getLocation().getImageUrl())
                        .collect(Collectors.toList())
        );

        return mypageResDto;
    }

    @Transactional
    public void deleteUser(Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        visitHistoryRepository.deleteByUser(user);
        bookmarkRepository.deleteByUser(user);
        alarmMuteRepository.deleteByUser(user);

        userRepository.delete(user);
    }

    public List<BookmarkDto> getBookmarks(Long userId) {
        return bookmarkRepository.findByUserIdOrderByModifiedAtDesc(userId)
                .stream()
                .map(bookmark -> {
                    BookmarkDto dto = new BookmarkDto();
                    dto.setLocationId(bookmark.getLocation().getId());
                    dto.setImageUrl(bookmark.getLocation().getImageUrl());
                    dto.setLocationName(bookmark.getLocation().getLocationName());
                    dto.setBookmarkTime(bookmark.getModifiedAt());  // 방문 시간을 설정
                    return dto;
                })
                .collect(Collectors.toList());
    }

    public List<VisitHistoryDto> getVisitHistories(Long userId) {
        return visitHistoryRepository.findByUserIdOrderByModifiedAtDesc(userId)
            .stream()
            .map(visit -> {
                VisitHistoryDto dto = new VisitHistoryDto();
                dto.setLocationId(visit.getLocation().getId());
                dto.setImageUrl(visit.getLocation().getImageUrl());
                dto.setLocationName(visit.getLocation().getLocationName());
                dto.setVisitedTime(visit.getModifiedAt());  // 방문 시간을 설정
                return dto;
            })
            .collect(Collectors.toList());
    }

    @Transactional
    public void addBookmark(Long userId, Long locationId) {
        // User 찾기
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Location 찾기
        Location location = locationRepository.findById(locationId)
                .orElseThrow(() -> new RuntimeException("Location not found"));

        // 이미 북마크가 존재하는지 확인 (중복 방지)
        boolean exists = bookmarkRepository.existsByUserAndLocation(user, location);
        if (exists) {
            throw new RuntimeException("Bookmark already exists for this location");
        }

        // Bookmark 생성
        Bookmark bookmark = new Bookmark();
        bookmark.setUser(user);
        bookmark.setLocation(location);
        bookmarkRepository.save(bookmark);

//        return bookmark;
    }

    @Transactional
    public void addAlarmMute(Long userId, Long locationId) {
        // User 찾기
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Location 찾기
        Location location = locationRepository.findById(locationId)
                .orElseThrow(() -> new RuntimeException("Location not found"));

        // 이미 알람 뮤트가 존재하는지 확인 (중복 방지)
        boolean exists = alarmMuteRepository.existsByUserAndLocation(user, location);
        if (exists) {
            throw new RuntimeException("AlarmMute already exists for this location");
        }

        AlarmMute alarmMute = new AlarmMute();
        alarmMute.setUser(user);
        alarmMute.setLocation(location);
        alarmMuteRepository.save(alarmMute);

    }

    @Transactional
    public void deleteBookmark(Long userId, Long locationId) {
        // User 찾기
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Location 찾기
        Location location = locationRepository.findById(locationId)
                .orElseThrow(() -> new RuntimeException("Location not found"));


        Bookmark bookmark = bookmarkRepository.findByUserAndLocation(user, location)
                .orElseThrow(() -> new RuntimeException("Bookmark not found"));

        // 북마크 삭제
        bookmarkRepository.delete(bookmark);
    }

    @Transactional
    public void deleteAlarmMute(Long userId, Long locationId) {
        // User 찾기
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Location 찾기
        Location location = locationRepository.findById(locationId)
                .orElseThrow(() -> new RuntimeException("Location not found"));

        AlarmMute alarmMute = alarmMuteRepository.findByUserAndLocation(user, location)
                .orElseThrow(() -> new RuntimeException("AlarmMute not found"));

        alarmMuteRepository.delete(alarmMute);
    }

    public List<AlarmMuteDto> getAlarmMute(Long userId) {
        return alarmMuteRepository.findByUserIdOrderByModifiedAtDesc(userId)
                .stream()
                .map(alarmMute -> {
                    AlarmMuteDto dto = new AlarmMuteDto();
                    dto.setLocationId(alarmMute.getLocation().getId());
                    dto.setImageUrl(alarmMute.getLocation().getImageUrl());
                    dto.setLocationName(alarmMute.getLocation().getLocationName());
                    dto.setAlarmMuteTime(alarmMute.getModifiedAt());  // 방문 시간을 설정
                    return dto;
                })
                .collect(Collectors.toList());
    }
}
