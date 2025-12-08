package com.triptalker.triptalk.global.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.servers.Server;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.Arrays;

@Configuration
public class SwaggerConfig {
//    @Value("${PRODUCTION_SERVER_URL}")
//    private String productionServerUrl;

    @Bean
    public OpenAPI customOpenAPI() {

        // 프로덕션 서버 설정
        Server productionServer = new Server();
        productionServer.setUrl("https://triptalk.store");
        productionServer.setDescription("Production server");

        // 로컬 서버 설정
        Server localServer = new Server();
        localServer.setUrl("http://localhost:8080");
        localServer.setDescription("Local server");

        return new OpenAPI()
                .servers(Arrays.asList(productionServer, localServer))
                .addSecurityItem(new SecurityRequirement().addList("BearerAuth"))
                .components(new Components()
                        .addSecuritySchemes("BearerAuth", new SecurityScheme()
                                .name("Authorization")
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")));
        }
}
