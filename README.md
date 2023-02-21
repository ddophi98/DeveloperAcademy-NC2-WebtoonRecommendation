# WebtoonTimes

## App Icon
<img width="100" alt="icon" src="https://user-images.githubusercontent.com/72330884/188558998-f170b4b2-da49-4a21-ace1-315b9b58b569.png">

## Introduction
대부분의 웹툰 플랫폼들은 장르별로만 웹툰을 분류합니다. 이러한 점에서 불편함을 느끼고 장르 뿐만 아니라 스토리 그리고 그림체 별로도 웹툰을 분류해줄 수 있는 앱을 만들어봤습니다.

## Functions
- 장르, 스토리, 그림체를 기준으로 웹툰들을 분류하고 비슷한 웹툰끼리 묶어서 보여줍니다.
- 원하는 웹툰을 쉽게 검색하고 상세 정보를 확인할 수 있게 해줍니다.
- 상세 화면에서는 웹툰의 여러 정보들을 보여줄 뿐만 아니라 실제 웹사이트로 연결해줍니다.

## Flow
- 웹 크롤링, 비지도 학습, 데이터 업로드를 거쳐서, 마지막으로 결과물을 앱에서 보여줍니다.
- 그림체 기준으로 분류한 것에 대해서는 네가지 방법을 시도해봤는데, 가장 성능이 괜찮았던 네번째 방법을 사용했습니다.
- 성능 측정 기준은 얼마나 많이 같은 작가의 웹툰을 유사한 웹툰으로 분류하는지로 파악했습니다.
<img width="1000" alt="image" src="https://user-images.githubusercontent.com/72330884/220370517-ddef240f-d5ef-461c-bf24-b5fc25e7780c.png">

## Screenshots
|장르 화면|스토리 화면|그림체 화면|
|---|---|---|
|<img width="200" alt="icon" src="https://user-images.githubusercontent.com/72330884/188559778-f75b1c65-fc8d-4ff6-a0ac-26f1183d0949.gif">|<img width="200" alt="icon" src="https://user-images.githubusercontent.com/72330884/188559935-33919ea7-a4b2-40ad-9420-c0d028814673.gif">|<img width="200" alt="icon" src="https://user-images.githubusercontent.com/72330884/188560096-31fe1b43-f595-4fa5-a723-ae0a4b03b6b7.gif">|

|검색 화면|상세 화면|
|---|---|
|<img width="200" alt="icon" src="https://user-images.githubusercontent.com/72330884/188561779-cf093442-51d1-40f7-a07d-35e1e985d83e.gif">|<img width="200" alt="icon" src="https://user-images.githubusercontent.com/72330884/188561968-915c6a21-9a66-4e3d-8354-61ce602d93bf.gif">|

## Development Environment
1. MacOS Monterey 12.4
2. XCode 13.4.1

## Tool
- 이슈 및 형상 관리: Github
- 디자인: Sketch
- 개발: XCode, PyCharm

## Skills
- Swift - UI 개발 (SwiftUI)   
- Python - 웹 크롤링, 토큰화 및 벡터화, 차원 축소, ML(k-means, style transfer), 이미지 특징 추출 (haralick, average hash)    
- Database - Firebase   
