package com.triptalker.triptalk.domain.service;

import com.triptalker.triptalk.domain.entity.Location;
import com.triptalker.triptalk.domain.repository.LocationDetailRepository;
import com.triptalker.triptalk.domain.repository.LocationRepository;
import jakarta.transaction.Transactional;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.context.SpringBootTest;

import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@SpringBootTest
@Transactional
@AutoConfigureTestDatabase
public class LocationConcurrencyTest {

    @Autowired
    private ApiService apiService;

    @Autowired
    private LocationRepository locationRepository;

    @Autowired
    private LocationDetailRepository locationDetailRepository;

    @Test
    public void 동시에_요청_시_API_한_번만_호출되고_중복_저장되지_않는다() throws InterruptedException {
        // given
        String tid = "352";
        String tlid = "1085";
        Location location = locationRepository.save(new Location(tid, tlid, "example"));

        int threadCount = 10;
        CountDownLatch latch = new CountDownLatch(threadCount);

        Runnable task = () -> {
            try {
                apiService.getLocationAudio(tid, tlid); // 외부 API 호출 + DB 저장 로직
            } finally {
                latch.countDown();
            }
        };

        ExecutorService executor = Executors.newFixedThreadPool(threadCount);
        for (int i = 0; i < threadCount; i++) {
            executor.submit(task);
        }

        latch.await(); // 모든 스레드 종료 대기

        // then
        List<LocationDetail> saved = locationDetailRepository.findByLocation(location);
        System.out.println("저장된 LocationDetail 개수: " + saved.size());

        assertThat(saved.size()).isGreaterThan(0); // 저장은 되어야 하고
        assertThat(saved.size()).isLessThanOrEqualTo(1); // 단 1건만 저장되어야 함 (또는 정확한 수)
    }
}
