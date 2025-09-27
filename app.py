from flask import Flask
import os, pymysql

app = Flask(__name__)
color = os.environ.get("APP_COLOR", "blue")
dbhost = os.environ.get("DBHOST", "mysql")
dbuser = os.environ.get("DBUSER", "root")
dbpwd = os.environ.get("DBPWD", "pw")

@app.route("/")
def index():
    status = "db-ok"
    try:
        conn = pymysql.connect(host=dbhost, user=dbuser, password=dbpwd, connect_timeout=2)
        conn.close()
    except Exception:
        status = "db-fail"
    return f"<html><body style='background:{color};'><h1>{color.upper()}</h1><p>DB:{status}</p></body></html>"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
