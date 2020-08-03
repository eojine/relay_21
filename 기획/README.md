# 릴레이 프로젝트

![_2020-07-31__2 53 51](https://user-images.githubusercontent.com/21030956/89019291-0b656a80-d358-11ea-82f2-f60358dc763c.png)

## 소개

## 버디버디란?

- 2000년 1월 13일 오픈해 2012년 5월 25일 서비스가 종료된 대한민국의 메신저
- 네이트온, MSN메신저에 이어 한국에서 3번째로 많이 사용되었던 메신저

### 버디버디의 특징

- 익명성
- 가벼움
- 미니 홈피

### 서비스 종료 이유

- 실명제인 네이트온과는 달리 가입할때는 실명인증이 필요했지만 **아이디는 자신이 원하는대로 생성 가능**
- 사생활 보호라는 익명성의 취지에는 괜찮았지만 **각종 범죄에 이용**되어 역기능적인 면이 많음
- 특히, **화상채팅방 목록들 중 상당수**가 친목목적을 도모한 **유사성매매방**일 정도
- 그 외 여러 이유들로 인해 자연스럽게 이용자들이 네이트온으로 이동하면서 버디버디가 쇠퇴

![Chill _tennodhesosmise](https://user-images.githubusercontent.com/21030956/89019282-099ba700-d358-11ea-8e03-2d6042a01d2c.jpg)

[15세 중학생 성기 사진공개하고 "동성 원조교제"](https://n.news.naver.com/mnews/article/008/0002224134)

### 개선 방향

> 버디버디의 부정적인 이슈를 최대한 해결하자.

1. 공통 개선 방향
   - 선정적, 폭력적인 컨텐츠 방지
   - A, B, C 기능 추가 구현
2. 기본 기능

- 메신저 ⇒ 채팅 기능 수행

  - 일대일 채팅방을 전제
  - 채팅 입력창을 통해 텍스트, 이미지를 첨부 가능
  - 채팅의 내용들은 상대방에게 전송
    ⇒ A, B, C에 의해 필터링을 수행 뒤 전송

  ![_2020-07-31__5 14 20](https://user-images.githubusercontent.com/21030956/89019279-07d1e380-d358-11ea-946a-bd4d729e499d.png)

  ![_2020-07-31__5 14 03](https://user-images.githubusercontent.com/21030956/89019270-056f8980-d358-11ea-80be-21cbfc71cee1.png)

## 결론

### 기능들의 활용 / 기대효과

- 해당 기능들을 활용해 기능 A와 기능 B를 통해 불쾌 컨텐츠를 선별할 수 있게 한다.
- 음란물 공유로 인한 문제들을 미리 예방한다.
- 비슷한 사용자들끼리 커뮤니티를 형성할 수 있다.
- 사용자들이 건전한 채팅 문화를 조성할 수 있다.





# 기능 명세

### A. 자연어 처리

- 기능 설명 :  채팅 내용을 자연어 처리를 통해 비속어 check

- 참고할 사이트

  - 딥러닝을 이용한 자연어 처리 입문 : [https://wikidocs.net/22530](https://wikidocs.net/22530)
  - 한글 토큰화 라이브러리 : [https://konlpy.org/en/latest/#standing-on-the-shoulders-of-giants](https://konlpy.org/en/latest/#standing-on-the-shoulders-of-giants)
  - 구글 유해성 검사(이미지) : [https://cloud.google.com/vision/docs/detecting-safe-search?hl=ko](https://cloud.google.com/vision/docs/detecting-safe-search?hl=ko)


- 해야할일

  - 비속어 용어 사전을 만들어야 함

  - 문장을 토큰화 시켜야함  → 라이브러리 사용

  - 신고 기능을 넣어 특정 단어를 추출 후, 비속어 사전에 추가 할 수 있는 방법을 고안

(더 필요한 부분이 있다면 추가해주세요....)

```java
public interface 채팅방 {
      Map<String,Integer> 음란어사전 = new HashMap<>(); //singleton
	    String[] 문장토큰으로분리(String sentence); 
      boolean 음란한단어인가(String token);
      void 음란지수카운트(User user, String sentence);
      void 신고하기(String token, User user);
      void 사전에단어등록(String token);
}
```

## 요구사항

- Database table 생성 및 example data insert(column data type은 적절하게)

  1. 선정성 여부를 나타내는 단어 사전 테이블 (dictionary)

     예)

     | word   | polarity |
     | ------ | -------- |
     | 빨간맛 | 1        |
     | 파란맛 | -1       |
     | 노란맛 | 0        |

  2. 채팅 로그 테이블

     예)

     | timestamp  | message     | User ID     | Chat room ID |
     | ---------- | ----------- | ----------- | ------------ |
     | 1596177088 | 안녕하세요? | S100_홍길동 | roomXX       |

     

- 분석에 필요한 data를 database에서 json 형식(혹은, 다른 적합한 형식)으로 가져오는 module 구현

- 단어 추출 module 구현(형태소 분석을 통해 유의미한 단어를 추출)

- dictionary를 이용해 message의 선정성 지수를 연산하는 모듈 구현





### B. 이미지 / 영상처리 (+ 인공지능)

- 목적 : 음란성 이미지를 검열하여 건전한 채팅문화 조성

- 프로세스 및 구현 예시(인스타그램 censor)

  ![KakaoTalk_20200731_151642767](https://user-images.githubusercontent.com/21030956/89019266-030d2f80-d358-11ea-8d0c-f5a690b4c31b.jpg)

![image](https://user-images.githubusercontent.com/21030956/89019560-6eef9800-d358-11ea-8264-cd02f9924b16.png)

- 예시 라이브러리

  [작은 데이터셋으로 강력한 이미지 분류 모델 설계하기](https://keraskorea.github.io/posts/2018-10-24-little_data_powerful_model/)

- 참고 링크 (순서대로 보는 것 권장)

[[P] Nudity detection and Censoring in images with Image Classification and Object Detection](https://www.reddit.com/r/MachineLearning/comments/b78j1q/p_nudity_detection_and_censoring_in_images_with/)

[NudeNet: An ensemble of Neural Nets for Nudity Detection and Censoring](https://medium.com/@praneethbedapudi/nudenet-an-ensemble-of-neural-nets-for-nudity-detection-and-censoring-d9f3da721e3?source=friends_link&sk=e19cdcc610e63b16274dd659050ea955)

[NudeNet: An ensemble of Neural Nets for Nudity Detection and Censoring](https://medium.com/@praneethbedapudi/nudenet-an-ensemble-of-neural-nets-for-nudity-detection-and-censoring-c8fcefa6cc92?source=friends_link&sk=f0a4786bf005cd4b7e89cf625f109af0)

### C . 예측 모델

![IMG_951163CC6BB6-1](https://user-images.githubusercontent.com/21030956/89019255-00123f00-d358-11ea-8501-458516a926e6.jpeg)






→ 대화 주제 추천? ⇒ 가입 단계에서 관심사를 입력 받아, 공통 관심사를 가진 사람들끼리 클러스터링 후 매칭.

→ 공통의 관심사를 가진 User 들이 추가로 갖고있는 관심사를 추천

<img src="https://user-images.githubusercontent.com/21030956/89019159-dfe28000-d357-11ea-8102-9691031b0cfe.png" width="400">



<img src="https://user-images.githubusercontent.com/21030956/89019103-c6d9cf00-d357-11ea-954e-b16b6d0f8e93.jpeg" width="400">





##### Example Table

| Name  | 관심사 | 관심사2 | 관심사3 |
| ----- | ------ | ------- | ------- |
| User1 | 영화   | 운동    | 게임    |
| User2 | 영화   | 운동    | 게임    |
| User3 | 영화   | 운동    |         |



Ex) 영화와 운동을 같이 관심있어 하는 사람들이 공통적으로 어떤 것에 관심이 있는지 테이블에서 예측해 대화 주제로 추천해준다.

(카테고리 별로 다른 항목에 대해 연결되어있는 수에 따라 가중치를 두고 계산한다.)

- 사용자가 관심사가 비슷한 그룹이 추가로 관심있어 하는 관심사를 추천

  ⇒ 해당하는 데이터 예측 모델을 생성

[추천 시스템 알고리즘 - 기존 주요 추천 엔진과 작동 방법](
