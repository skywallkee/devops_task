from flask import Flask, jsonify
from pymongo import MongoClient
from datetime import datetime
from prometheus_flask_exporter import PrometheusMetrics
from prometheus_client import Gauge, generate_latest
import logging
import os
import json
import psutil

app = Flask(__name__)

# Initialize PrometheusMetrics to expose the /metrics endpoint
metrics = PrometheusMetrics(app)

# Setup logging to write to a file
log_file_path = '/var/log/flask_app.log'
logging.basicConfig(level=logging.INFO, format='%(asctime)s %(message)s', handlers=[logging.FileHandler(log_file_path), logging.StreamHandler()])

# Setup MongoDB connection
# Update the connection string as per your MongoDB setup
mongo_uri = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
client = MongoClient(mongo_uri)
db = client.ping_database
collection = db.pings

# Create Prometheus Gauges for system metrics
cpu_usage_gauge = Gauge('system_cpu_usage', 'System CPU Usage')
memory_usage_gauge = Gauge('system_memory_usage', 'System Memory Usage')

@app.route('/ping', methods=['GET'])
def ping():
    # Record the ping with a timestamp
    result = collection.insert_one({'message': 'ping', 'timestamp': datetime.utcnow()})
    
    # Log the ping
    logging.info(json.dumps({'event': 'PingReceived', 'id': str(result.inserted_id), 'timestamp': datetime.utcnow().isoformat()}))
    
    return jsonify({'message': 'Ping recorded', 'id': str(result.inserted_id)})

@app.route('/metrics', methods=['GET'])
def metrics():
    # Update system metrics
    cpu_usage_gauge.set(psutil.cpu_percent())
    memory_usage_gauge.set(psutil.virtual_memory().percent)
    
    # Generate and return the latest metrics
    return generate_latest()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
