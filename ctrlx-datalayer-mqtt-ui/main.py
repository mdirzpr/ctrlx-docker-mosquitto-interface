from flask import Flask, request, render_template
import os
import sys

app = Flask(__name__)


@app.route('/')
def home():
    return render_template('index.html')


@app.route('/', methods=['POST'])
def my_form_post():
    text = request.form['path']
    print(text, file=sys.stderr)
    return render_template('index.html')


if __name__ == "__main__":
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
