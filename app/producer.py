# producer.py
import json
from confluent_kafka import Producer
from config import KAFKA_CONFIG
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleProducer:
    def __init__(self, topic: str):
        self.topic = topic
        self.producer = Producer(KAFKA_CONFIG)
    
    def delivery_callback(self, err, msg):
        """Callback for message delivery reports"""
        if err:
            logger.error(f'Message delivery failed: {err}')
        else:
            logger.info(f'Message delivered to {msg.topic()} [{msg.partition()}] at offset {msg.offset()}')
    
    def send_message(self, key: str, value: dict):
        """Send a message to Kafka"""
        try:
            self.producer.produce(
                topic=self.topic,
                key=key.encode('utf-8'),
                value=json.dumps(value).encode('utf-8'),
                callback=self.delivery_callback
            )
            # Trigger delivery report callbacks
            self.producer.poll(0)
        except Exception as e:
            logger.error(f'Error producing message: {e}')
    
    def flush(self):
        """Wait for all messages to be delivered"""
        self.producer.flush()

# Usage example
if __name__ == '__main__':
    producer = SimpleProducer(topic='test-topic')
    
    # Send some messages
    for i in range(5):
        producer.send_message(
            key=f'key-{i}',
            value={'message_id': i, 'data': f'test message {i}'}
        )
    
    # Ensure all messages are sent
    producer.flush()
    logger.info('All messages sent')