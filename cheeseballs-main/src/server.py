from flask import Flask, jsonify
import json

app = Flask(__name__)

@app.route('/fun-purchases')
def get_fun_purchases():
    try:
        with open('purchases.json', 'r') as file:
            purchases = json.load(file)
        return jsonify({
            "status": "success",
            "data": purchases
        })
    except FileNotFoundError:
        return jsonify({
            "status": "error",
            "message": "Purchases data not found"
        }), 404

if __name__ == '__main__':
    app.run(debug=True, port=8000) 