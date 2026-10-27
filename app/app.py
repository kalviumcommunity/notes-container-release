import os

import psycopg
import redis
from flask import Flask, jsonify

app = Flask(__name__)
DATABASE_URL = os.environ["DATABASE_URL"]
REDIS_URL = os.environ["REDIS_URL"]


def check_database():
    try:
        with psycopg.connect(DATABASE_URL, connect_timeout=3) as conn:
            conn.execute("SELECT 1")
        return "connected"
    except Exception:
        return "unreachable"


def check_cache():
    try:
        redis.Redis.from_url(REDIS_URL, socket_connect_timeout=3).ping()
        return "connected"
    except Exception:
        return "unreachable"


@app.get("/health")
def health():
    database, cache = check_database(), check_cache()
    ok = database == "connected" and cache == "connected"
    body = {
        "service": "notes-web",
        "status": "ok" if ok else "degraded",
        "database": database,
        "cache": cache,
    }
    return jsonify(body), 200 if ok else 503


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", "5000")))
