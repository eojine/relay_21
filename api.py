# -- coding: utf-8 --
import flask
from flask import request, jsonify, make_response, Response
from bs4 import BeautifulSoup
from urllib.request import urlopen
import urllib.request
from urllib.parse import urlparse
import requests
import json
import time
import sys

import realEstate
app = flask.Flask(__name__)
app.config["RELEASE"] = True

@app.route('/<location_name>', methods=['GET'])
def home(location_name):
    print('get root')
    result = realEstate.run_real_estate(location_name)
    res = json.dumps(result, ensure_ascii=False).encode('utf8')
    return Response(res, content_type='application/json;charset=utf-8')

#    return "<h1>Welcome Home</h1>"

app.run(host= '0.0.0.0', port=5000, debug=False)

