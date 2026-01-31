# TripTalk(트립톡) 
<img width="827" height="372" alt="image" src="https://github.com/user-attachments/assets/f81e61d2-8daf-4a31-b581-a5a520e13128" /> <br>
ㅇ 위치 기반 관광 가이드 서비스<br>
ㅇ 서비스 개발 기간: 2024. 05. 21.(화) → 2024. 10. 01.(화)<br>
ㅇ 개발 범위: MVP(**Minimum Viable Product)**  <br>

## 목차

- 서비스 대상
- 개발 배경
- 서비스 화면
- 공공데이터 활용 방안

## 서비스 대상

---

본 서비스는 **개별 자유여행객(FIT)** 을 주요 대상으로 선정.

특히, 다음과 사용자에 특화된 서비스임.

- **20~30대 MZ세대층 관광객**
    - 패키지 여행보다 자유여행을 선호
    - 지도·검색의 복잡성보다 음성 안내와 스토리텔링형의 정보를 추구
    - 공동 여과로 나의 취향에 맞는 새로운 여행지 추천을 원함
- **국내·외 관광객**
    - 언어 장벽으로 인한 관광 정보의 접근성 해소 요구
    - 낯선 지역에서의 여행에서 안정성을 원하는 관광

## 개발 배경

---

- 기존 관광 정보 서비스의 **한계**
    - 관광 정보가 **텍스트·지도 위주**로 제공됨
    - 사용자가 직접 검색·선택해야 하는 **수동적 정보 탐색 구조**
    - 지역별 공공 관광 데이터가 **파편화되어 활용도가 낮음**
- 최근 관광 **트렌드의** **변화**
    - 오디오 가이드, 팟캐스트형 콘텐츠 소비 증가
    - AI 기반 맞춤형 플랫폼 서비스 확대
    - 실시간 위치 기반 서비스(LBS) 대중화

이에 본 프로젝트는

👉 **공공 관광데이터 + 위치 기반 기술 + AI 음성 인터페이스**를 결합하여
관광객에게 **상황 인지형, 능동 제공형 관광 가이드 서비스**를 제공하고자 함.

## 서비스 화면



###  일일이 가이드를 찾거나, 시간을 맞출 필요 없는 오로지 나를 위한 여행 가이드 어플리케이션 

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ
<style>
  .step-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    border: 2px solid #000;
    gap: 0;
    max-width: 1100px;
    margin: 0 auto;
  }

  .step-card {
    border-right: 2px solid #000;
    display: grid;
    grid-template-rows: 1fr auto; /* 위=이미지, 아래=설명 */
    min-height: 420px;            /* 전체 높이(원하면 조절) */
    background: #fff;
  }
  .step-card:last-child { border-right: 0; }

  .step-img {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 10px;
    border-bottom: 2px solid #000;
    overflow: hidden;
  }
  .step-img img {
    width: 100%;
    height: 100%;
    max-height: 320px;  /* 이미지 영역 높이(원하면 조절) */
    object-fit: contain; /* 이미지 잘림 없이 맞추기 */
  }

  .step-text {
    padding: 12px 14px;
    font-size: 15px;
    line-height: 1.5;
  }

  /* 모바일에서 2열/1열로 자동 변경 */
  @media (max-width: 900px) {
    .step-grid { grid-template-columns: repeat(2, 1fr); }
    .step-card:nth-child(2) { border-right: 0; }
    .step-card:nth-child(3), .step-card:nth-child(4) { border-top: 2px solid #000; }
  }
  @media (max-width: 520px) {
    .step-grid { grid-template-columns: 1fr; }
    .step-card { border-right: 0; border-top: 2px solid #000; }
    .step-card:first-child { border-top: 0; }
  }
</style>

<div class="step-grid">
  <div class="step-card">
    <div class="step-img">
      <img src="step1.png" alt="step 1">
    </div>
    <div class="step-text">
      1. 트립톡의 검색창에 원하는 관광지를 검색한다.
    </div>
  </div>

  <div class="step-card">
    <div class="step-img">
      <img src="step2.png" alt="step 2">
    </div>
    <div class="step-text">
      2. 화면에 뜬 관광지 중 원하는 관광지를 클릭한다.
    </div>
  </div>

  <div class="step-card">
    <div class="step-img">
      <img src="step3.png" alt="step 3">
    </div>
    <div class="step-text">
      3. 관광지 정보를 확인한다.<br>
      (카카오맵 단계별(구), 동네예보) 조회서비스 활용
    </div>
  </div>

  <div class="step-card">
    <div class="step-img">
      <img src="step4.png" alt="step 4">
    </div>
    <div class="step-text">
      4. 가이드 버튼을 누른다.
    </div>
  </div>
</div>

ㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡㅡ

## 👨‍🏫 서비스 개요

<br><br>

<table> 
  <tr> 
    <td align="center"> <b>위치 기반<br>관광지 오디오 가이드 제공</b><br><br> <img src="이미지링크1" width="230"/> </td> 
    <td align="center"> <b>ㄱㄱ<br>ㄱㄱ</b><br><br> <img src="이미지링크2" width="230"/> </td> 
    <td align="center"> <b>ㄱㄱㄱ<br>ㄱㄱ</b><br><br> <img src="이미지링크3" width="230"/> </td> 
  </tr> 
  <tr> 
    <td align="center"> <b>ㄱㄱ<br>ㄱㄱ</b><br><br> <img src="이미지링크4" width="230"/> </td> 
    <td align="center"> <b>ㄱㄱ<br>ㄱㄱ</b><br><br> <img src="이미지링크5" width="230"/> </td> 
    <td align="center"> <b>음성 인식 기반 <br>대화형 
AI</b><br><br> <img src="이미지링크6" width="230"/> </td> 
  </tr> 

</table>


<br><br>

<br><br>



## 📱 페이지 별 기능

<br><br>
<br><br>


## 👨‍👨‍👧‍👧 팀원

<table>
  <tr>
    <td align="center"><a href="https://github.com/KimGiheung"><img src="https://avatars.githubusercontent.com/u/98355440?v=4" width="100px;" alt=""/>
    <td align="center"><a href="https://github.com/erase-jeong"><img src="https://avatars.githubusercontent.com/u/98355440?v=4" width="100px;" alt=""/>
    <td align="center"><a href="https://github.com/wjdheesp44"><img src="https://avatars.githubusercontent.com/u/49576104?v=4" width="100px;" alt=""/>
    <td align="center"><a href="https://github.com/wjdheesp44"><img src="https://avatars.githubusercontent.com/u/49576104?v=4" width="100px;" alt=""/>
  </tr>
    <tr>
    <td align="center"><a href="https://github.com/KimGiheung" title="Code">김기흥(AI) </a></td>
    <td align="center"><a href="https://github.com/erase-jeong" title="Code">정지우(Front) </a></td>
    <td align="center"><a href="https://github.com/wjdheesp44" title="Code">정희수(BackEnd)</a></td>
    <td align="center"><a href="https://github.com/wjdheesp44" title="Code">배지혜(Design)</a></td>
  </tr>
</table>
<br><br>

|  |  |  |  |
|---|---|---|---|
| ![step1](step1.png) | ![step2](step2.png) | ![step3](step3.png) | ![step4](step4.png) |
| 1. 트립톡의 검색창에 원하는 관광지를 검색한다. | 2. 화면에 뜬 관광지 중 원하는 관광지를 클릭한다. | 3. 관광지 정보를 확인한다. (카카오맵 단계별(구), 동네예보) 조회서비스 활용 | 4. 가이드 버튼을 누른다. |


<img width="819" height="385" alt="image" src="https://github.com/user-attachments/assets/e8434880-c27c-458e-b80e-d187b38158c4" />


## ⚙️ 개발환경

