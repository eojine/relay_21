## Relay 21
![_2020-07-31__2 53 51](https://user-images.githubusercontent.com/21030956/89019291-0b656a80-d358-11ea-82f2-f60358dc763c.png)

[서비스조사](Documents/ProjectResearch.md)  
[기능 설계](Documents/ProjectDesign.md)

---
## 참여자
1주차 : 정재명, 정택현, 조경환, 조기현, 조송주, 조수정, 조인택, 조정래, 김병인, 김석호, 김승언, 김신우  
2주차 : 이은정, 권지웅, 박재현, 허경영, 현기엽, 김근수, 심영민, 이지원, 조경환, 정택현, 양어진  
3주차 :   
4주차 :   



## 2주차

### FrontEnd

- cocoaPods
- `MessageKit`
- Program Flow
- MessageKit으로 UI 구성
- 메세지 작성 후 보내기 할 때, Server에 해당 message에 대한 유해성 검사
- 검사 후 넘어온 data를 message로 전송

### BackEnd

1. 서버 Flask, Django, Spring중  Flask로 서버 선택
2. Flask 개발 환경 설정을 했다.
3. 메세지를 받을 때 NLP라이브러리로 욕설부분만 " * "로 변환한다.
4. 변환한 메세지를 Front로 json형식으로 보낸다.

### 실행결과

<img src="./1.png" width = "40%">
<img src="./2.png" width = "40%">
<img src="./3.gif" width = "40%">