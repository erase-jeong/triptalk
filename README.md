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

#### ㅇ (메인 기능) 자동/수동 관광 및 AI 음성 대화 기능
<table style="width:100%; table-layout:fixed; border-collapse:collapse;">
  <tr>
    <td colspan="9" style="padding:0; border:0;">
      <div style="width:100%; overflow-x:auto; overflow-y:hidden; -webkit-overflow-scrolling:touch;">
        <table style="border-collapse:collapse;">
          <!-- 이미지 행 -->
            <tr>
                <td style="padding:0;">
                    <img alt="step1" src="https://github.com/user-attachments/assets/029a1851-c2e9-4f6b-952d-97683190e0c1"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step2" src="https://github.com/user-attachments/assets/9d3da0ac-209d-47d2-9b3e-b7c75b603635"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step3" src="https://github.com/user-attachments/assets/de9a0b88-b2cc-4d3a-86b9-cfd9081a459f"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step4" src="https://github.com/user-attachments/assets/c3605ef3-3419-414a-a7df-69281eefc69c"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step5-1" src="https://github.com/user-attachments/assets/3fabcde7-3ed3-489f-b67a-f2fe6673ffae"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step5-2" src="https://github.com/user-attachments/assets/fb880c57-f279-4aab-a11a-9fd573b0f102"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step6-1" src="https://github.com/user-attachments/assets/5b23511a-3226-4c83-8fef-008a5880d0c4"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step6-2" src="https://github.com/user-attachments/assets/4c3f5e97-44cf-490a-977f-84243778089e"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
                <td style="padding:0;">
                    <img alt="step6-3" src="https://github.com/user-attachments/assets/17f8dac1-4ab5-4f60-9697-81c112728056"
                         style="display:block; width:240px; height:520px; object-fit:cover;" />
                </td>
            </tr>
            <tr>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                  <strong style="font-size:1.1em; line-height:1.3;">
                      1. 트립톡에서 관광지 검색
                  </strong>
              </td>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">2. 관광지 선택
                </strong>
              </td>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">3. 관광지 관련 정보 확인
                </strong>
              </td>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">4. 수동/자동 가이드 선택
                </strong>
              </td>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
                  5.1 자동 가이드 선택 시 추천<br>
                  경로와 스팟, 오디오 가이드가 뜸
                </strong>
              </td>
              <td style="width:240px; padding:6px 8px; vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
                    5.2 수동 가이드 시 추천 경로는<br> 
                    뜨지 않음
                </strong>
              <td colspan="3" style="width:720px; padding:6px 8px;vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    6. 가이드 종료 후 대화 기능을 통해 궁금한 것을 음성으로 문답 가능
                </strong>
              </td>
            </tr>
        </table>
      </div>
    </td>
  </tr>
</table>

#### ㅇ (서브 기능) 주변 관광지 알림 및 관광지 저장 기능
<table style="width:100%; table-layout:fixed; border-collapse:collapse;">
  <tr>
    <td colspan="9" style="padding:0; border:0;">
      <div style="width:100%; overflow-x:auto; overflow-y:hidden; -webkit-overflow-scrolling:touch;">
        <table style="border-collapse:collapse;">
          <!-- 이미지 행 -->
            <tr>
              <!--주변 관광지 알리미 기능 흐름도-->
                <td style="padding:0;">
                    <img width="182" height="382" alt="image" src="https://github.com/user-attachments/assets/26969093-89f5-46a4-94b5-53c083eacf95" 
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
                </td>
                <td style="padding:0;">
                    <img width="182" height="381" alt="image" src="https://github.com/user-attachments/assets/1da3fc1d-8d7b-49b0-8a82-6dbca8db5625" 
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
                </td>
                <td style="padding:0;">
                <img width="181" height="383" alt="image" src="https://github.com/user-attachments/assets/7728f05a-e372-4e50-8305-d3d83e5dc2d1"
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
              <!--방문 기록 및 북마크 기능-->
                </td>
                <td style="padding:0;">
                    <img width="180" height="383" alt="image" src="https://github.com/user-attachments/assets/1ac43eb6-5bfb-4a0d-be8e-ccee09fc8ec0"
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
                </td>
                <td style="padding:0;">
                    <img width="183" height="382" alt="image" src="https://github.com/user-attachments/assets/f30e6fb6-dd84-4506-a847-d4e40646e803"
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
                </td>
                <td style="padding:0;">
                    <img width="177" height="382" alt="image" src="https://github.com/user-attachments/assets/88dcdde0-fd75-49fd-a273-72f105319963"
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
              <!--매거진 기능 흐름도-->
                </td>
                <td style="padding:0;">
                    <img width="187" height="387" alt="image" src="https://github.com/user-attachments/assets/925ed5e8-f03d-4bed-a2ec-33c254f96164"
                         style="display:block; width:240px; height:520px; object-fit:cover;"/>
                </td>
            </tr>
          <!--설명 부분-->
            <tr>
              <td colspan="3" style="width:720px; padding:6px 8px;vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    주변 광광지 알림 기능
                </strong>
              <td colspan="3" style="width:720px; padding:6px 8px;vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    방문 기록 저장 및 북마크 기능
                </strong>
              <td colspan="3" style="width:720px; padding:6px 8px;vertical-align:middle;">
                <strong style="font-size:1.1em; line-height:1.3;">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    트립톡 매거진
                 </strong>
              </td>
            </tr>
        </table>
      </div>
    </td>
  </tr>
</table>

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

