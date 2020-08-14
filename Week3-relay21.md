# Week3 relay21

참여자



## 기능A 실행하기

1. git clone https://github.com/boostcamp-2020/relay_21.git

2. relay21/BE 폴더에서

   - pip3 install -r requirements.txt

   - 이 때, 오류가 나는 line 모두 지우기

3. Sources/Extensions/Networkhelper.swift

   - private let baseUrl = "http://49.50.166.93/hello"를  private let baseUrl = "http://0.0.0.0/hello"로 바꿔주기

4. Xcode에서 relay21/FE 폴더 열기 -> run

5. 터미널에서 flask run -h 0.0.0.0 -p 80



## FE

### 기능

1. 사용자가 업로드할 사진을 선택

   - 방법1 : url 입력칸이 있고, url을 입력하면 해당 url의 사진을 사용
   - 방법2 : 사진 사용자가 선택해서 실제로 서버에 업로드
     - 서버에 전송
     - 서버로부터 유해성 판단 후 다시 돌려준 이미지를 다시 화면에 보여주기

   

2. 블러일 경우, 사진을 터치해서 블러 효과를 제거



## BE(Python, Flask)

### API

1. UIBlurEffect (iOS에서 블러처리하는 API) : https://developer.apple.com/documentation/uikit/uiblureffect
2. Core ML & Vision on iOS (iOS 머신러닝)
   - 블로그 : http://throughkim.kr/2017/09/06/ios-coreml/
   - 콫 모델 생성 트레이닝 : https://developer.apple.com/documentation/vision/training_a_create_ml_model_to_classify_flowers
3. keras model : https://github.com/mtobeiyf/keras-flask-deploy-webapp
4. Xcode create ML



### 기능

1. 사용자로부터 전송받은 사진에 대해 유해성 검사
   - 블러처리/원본 이미지를 다시 전송
     - 유해하지 않다면 원본사진 그대로 사용자에게 다시 전송
     - 유해한 사진일 경우, 블러처리한 이미지를 사용자에게 다시 전송
   - 단순히 boolean 값으로 결과를 전송







**One or more media items failed to import:**

**/Users/sihyungyou/Desktop/cat1.jpg: The operation couldn’t be completed. (PHPhotosErrorDomain error -1.)**