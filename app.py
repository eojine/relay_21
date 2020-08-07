import nltk
nltk.download('punkt')
from flask import Flask, Response, request, jsonify
from nltk.tokenize import word_tokenize
import badwords
app = Flask(__name__)
app.config["RELEASE"] = True
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
def profanityAnalysis(input):
    word_tokens = word_tokenize(input)
    result = []
    for w in word_tokens:
        if w not in badwords.badwords:
            result.append(w + " ")
        else:
            result.append("*" * len(w))
    return "".join(result)
app.run(host= '0.0.0.0', port=5000, debug=False)
