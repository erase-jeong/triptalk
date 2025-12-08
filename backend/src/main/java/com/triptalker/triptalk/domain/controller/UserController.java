package com.triptalker.triptalk.domain.controller;

import com.triptalker.triptalk.domain.dto.*;
import com.triptalker.triptalk.domain.entity.AlarmMute;
import com.triptalker.triptalk.domain.service.UserService;
import com.triptalker.triptalk.global.BaseResponse;
import com.triptalker.triptalk.global.jwt.JWTUtil;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.Date;
import java.util.List;

@Slf4j
@RestController
@RequiredArgsConstructor
public class UserController {

    private final UserService userService;
    private final JWTUtil jwtUtil;

    @Operation(summary = "카카오 로그인 API")
    @PostMapping("/v1/users/kakao-login")
    public BaseResponse<String> kakaoLogin(@RequestBody RegisterReqDto registerReqDto) {
        System.out.println("start kakao login");
        System.out.println(registerReqDto.getKakaoId());
        String token = userService.kakaoRegister(registerReqDto);
        log.info("kakao login token : Bearer {}", token);
        return new BaseResponse<>(token);
    }

    @Operation(summary = "마이페이지 가져오기 API")
    @GetMapping("/v1/users/mypage")
    public BaseResponse<MypageResDto> getMypage() {
        Long userId = userService.getCurrentUserId();
        MypageResDto mypageResDto = userService.getMypage(userId);
        return new BaseResponse<>(mypageResDto);
    }

    @Operation(summary = "회원탈퇴 API")
    @DeleteMapping("/v1/users")
    public ResponseEntity<String> deleteUser() {
        Long userId = userService.getCurrentUserId();
        userService.deleteUser(userId);
        return ResponseEntity.ok("User deleted successfully");
    }

    @Operation(summary = "최근 토커들이 북마크한 관광지 가져오기 API")
    @GetMapping("/v1/magazine/recent-bookmarks")
    public BaseResponse<List<RecentBookmarkDto>> getRecentBookmarks() {
//        Long userId = userService.getCurrentUserId();
        List<RecentBookmarkDto> bookmarks = userService.getRecentBookmarks();
        return new BaseResponse<>(bookmarks);
    }

    @Operation(summary = "북마크 가져오기 API")
    @GetMapping("/v1/bookmarks")
    public BaseResponse<List<BookmarkDto>> getBookmarks() {
        Long userId = userService.getCurrentUserId();
        List<BookmarkDto> bookmarks = userService.getBookmarks(userId);
        return new BaseResponse<>(bookmarks);
    }

    @Operation(summary = "북마크 추가 API", description = "북마크 추가 API")
    @PostMapping("/v1/bookmarks/{locationId}")
    public ResponseEntity<String> addBookmark(@PathVariable Long locationId) {
        Long userId = userService.getCurrentUserId();
        userService.addBookmark(userId, locationId);
        return ResponseEntity.ok("Bookmark added successfully");
    }

    @Operation(summary = "북마크 삭제 API")
    @DeleteMapping("/v1/bookmarks/{locationId}")
    public ResponseEntity<String> deleteBookmark(@PathVariable Long locationId) {
        Long userId = userService.getCurrentUserId();
        userService.deleteBookmark(userId, locationId);
        return ResponseEntity.ok("Bookmark deleted successfully");
    }

    @Operation(summary = "알람뮤트 가져오기 API")
    @GetMapping("/v1/alarm-mutes")
    public BaseResponse<List<AlarmMuteDto>> getAlarmMutes() {
        Long userId = userService.getCurrentUserId();
        log.info("get alarm mutes");
        List<AlarmMuteDto> alarmMutes = userService.getAlarmMute(userId);
        return new BaseResponse<>(alarmMutes);
    }

    @Operation(summary = "알람뮤트 리스트에서 추가 API")
    @PostMapping("/v1/alarm-mutes/{locationId}")
    public ResponseEntity<String> addAlarmMute(@PathVariable Long locationId) {
        Long userId = userService.getCurrentUserId();
        userService.addAlarmMute(userId, locationId);
        return ResponseEntity.ok("AlarmMute added successfully");
    }

    @Operation(summary = "알람뮤트 리스트에서 삭제 API")
    @DeleteMapping("/v1/alarm-mutes/{locationId}")
    public ResponseEntity<String> deleteAlarmMute(@PathVariable Long locationId) {
        Long userId = userService.getCurrentUserId();
        userService.deleteAlarmMute(userId, locationId);
        return ResponseEntity.ok("AlarmMute deleted successfully");
    }

    @Operation(summary = "방문기록 가져오기 API")
    @GetMapping("/v1/visit-histories")
    public BaseResponse<List<VisitHistoryDto>> getVisitHistories() {
        Long userId = userService.getCurrentUserId();
        List<VisitHistoryDto> histories = userService.getVisitHistories(userId);
        return new BaseResponse<>(histories);
    }

    @Operation(hidden = true)
    @GetMapping("/access")
    public String access() {
        Long userId = userService.getCurrentUserId();

        return userId != null ? "Current User ID: " + userId : "User not authenticated";
//        return "ok";
    }



}
