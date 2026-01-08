# config.py
import os
from dotenv import load_dotenv

load_dotenv()

KAFKA_CONFIG = {
    'bootstrap.servers': os.getenv('KAFKA_BOOTSTRAP_SERVERS', 'localhost:9092'),
    'security.protocol': os.getenv('KAFKA_SECURITY_PROTOCOL', 'PLAINTEXT'),
}

# For Confluent Cloud, add these to your .env:
# KAFKA_BOOTSTRAP_SERVERS=pkc-xxxxx.us-east-1.aws.confluent.cloud:9092
# KAFKA_SECURITY_PROTOCOL=SASL_SSL
# KAFKA_SASL_MECHANISM=PLAIN
# KAFKA_SASL_USERNAME=your-api-key
# KAFKA_SASL_PASSWORD=your-api-secret

if os.getenv('KAFKA_SASL_USERNAME'):
    KAFKA_CONFIG.update({
        'sasl.mechanism': os.getenv('KAFKA_SASL_MECHANISM', 'PLAIN'),
        'sasl.username': os.getenv('KAFKA_SASL_USERNAME'),
        'sasl.password': os.getenv('KAFKA_SASL_PASSWORD'),
    })