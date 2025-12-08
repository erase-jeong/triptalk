package com.triptalker.triptalk.domain.controller;

import com.triptalker.triptalk.domain.dto.JoinDto;
import com.triptalker.triptalk.domain.service.UserService;
import io.swagger.v3.oas.annotations.Operation;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class JoinController {

    private final UserService userService;

    public JoinController(UserService userService) {
        this.userService = userService;
    }

    @Operation(hidden = true)
    @PostMapping("/join")
    public String join(JoinDto joinDto) {

        System.out.println(joinDto.getUsername());
        userService.joinProcess(joinDto);

        return "ok";
    }
}
