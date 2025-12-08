package com.triptalker.triptalk;

import io.swagger.v3.oas.annotations.Operation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@Slf4j
@RestController
public class AppController {

    @Operation(summary = "test용 API")
    @GetMapping("/test")
    public String home() {
        try {
            return "Hello World";
        } catch (Exception e) {
            log.error("test error : {}", e.getMessage());
        }
        return "fail";
    }

}
