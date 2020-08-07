import badwords
import nltk
nltk.download('punkt')
from flask import Flask, Response, request, jsonify
from nltk.tokenize import word_tokenize
from flask_cors import  CORS, cross_origin
app = Flask(__name__)
app.config["RELEASE"] = True
CORS(app)
@app.route('/hello', methods=['POST'])
def home():
    data = request.get_json()
    user_id = data.get("userId")
    sentence = data.get("sentence")
    sentence = profanityAnalysis(sentence)
    data = {
        "userId":user_id,
        "sentence":sentence
    }
    return jsonify(data)# 받아온 데이터를 다시 전송
@app.route('/report', methods=['POST'])
def report():
    data = request.get_json()
    report_word = data.get("report")
    badwords.badwords.append(report_word)
    # print(len(badwords.badwords))
    data = {
        "result":"감사합니다."
    }
    return jsonify(data)
def profanityAnalysis(input):
    word_tokens = word_tokenize(input)
    result = []
    for w in word_tokens:
        if w not in badwords.badwords:
            result.append(w + " ")
        else:
            result.append("*" * len(w))
    return "".join(result)
app.run(host= '0.0.0.0', port=80, debug=True)
