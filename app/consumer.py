# consumer.py
import json
from confluent_kafka import Consumer, KafkaError
from config import KAFKA_CONFIG
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class SimpleConsumer:
    def __init__(self, topic: str, group_id: str):
        self.topic = topic
        consumer_config = KAFKA_CONFIG.copy()
        consumer_config.update({
            'group.id': group_id,
            'auto.offset.reset': 'earliest',  # Start from beginning if no offset
            'enable.auto.commit': True,
        })
        self.consumer = Consumer(consumer_config)
        self.consumer.subscribe([topic])
    
    def consume_messages(self, timeout: float = 1.0):
        """Consume messages continuously"""
        try:
            while True:
                msg = self.consumer.poll(timeout=timeout)
                
                if msg is None:
                    continue
                
                if msg.error():
                    if msg.error().code() == KafkaError._PARTITION_EOF:
                        logger.info(f'Reached end of partition {msg.partition()}')
                    else:
                        logger.error(f'Consumer error: {msg.error()}')
                    continue
                
                # Process message
                key = msg.key().decode('utf-8') if msg.key() else None
                value = json.loads(msg.value().decode('utf-8'))
                
                logger.info(f'Received message - Key: {key}, Value: {value}, '
                           f'Partition: {msg.partition()}, Offset: {msg.offset()}')
                
        except KeyboardInterrupt:
            logger.info('Consumer interrupted')
        finally:
            self.consumer.close()
            logger.info('Consumer closed')

# Usage example
if __name__ == '__main__':
    consumer = SimpleConsumer(
        topic='test-topic',
        group_id='test-consumer-group'
    )
    consumer.consume_messages()