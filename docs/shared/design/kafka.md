# Integrating Ruby on Rails with Kafka

## Overview
Implementation notes and best practices for using Kafka in a Rails application.

## Producer (sending messages)

### Basic publish flow
```ruby
# Example executed from Rails Console
config = Rdkafka::Config.new({
  "bootstrap.servers" => "127.0.0.1:9092",
  "client.id" => "console-producer"
})
producer = config.producer

producer.produce(
  topic: "test-topic",
  payload: "Hello from Rails!",
  key: "key1"
)
producer.flush
producer.close
```

### Publishing from a controller
```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    
    if @user.save
      send_kafka_message("user_created", {
        user_id: @user.id,
        email: @user.email
      })
      render json: @user, status: :created
    end
  end

  private

  def send_kafka_message(event_type, data)
    config = Rdkafka::Config.new({
      "bootstrap.servers" => "127.0.0.1:9092",
      "client.id" => "controller-producer"
    })
    producer = config.producer
    
    producer.produce(
      topic: "user_events",
      payload: data.to_json,
      key: data[:user_id].to_s
    )
    producer.flush
    
  rescue Rdkafka::RdkafkaError => e
    Rails.logger.error "Kafka delivery failed: #{e.message}"
    
  ensure
    producer&.close
  end
end
```

### Sending encrypted payloads
```ruby
# Using ActiveRecord::Encryption
encryptor = ActiveRecord::Encryption.encryptor
encrypted_data = encryptor.encrypt("sensitive data")

producer.produce(
  topic: "encrypted-topic",
  payload: encrypted_data,
  key: "encrypted-key"
)
producer.flush
```

## Consumer (receiving messages)

### Consumer implemented with Rails Runner
```ruby
# app/consumers/kafka_consumer_runner.rb
class KafkaConsumerRunner
  def self.start
    new.run
  end

  def initialize
    @running = true
  end

  def run
    setup_signal_handlers
    start_consumer
  end

  private

  def setup_signal_handlers
    Signal.trap('TERM') { graceful_shutdown }
    Signal.trap('INT') { graceful_shutdown }
  end

  def start_consumer
    config = Rdkafka::Config.new({
      "bootstrap.servers" => ENV.fetch("KAFKA_BOOTSTRAP_SERVERS", "127.0.0.1:9092"),
      "group.id" => "rails-consumer-group",
      "auto.offset.reset" => "earliest",
      "enable.auto.commit" => false
    })
    
    consumer = config.consumer
    consumer.subscribe("user_events")

    while @running
      consumer.each do |message|
        process_message(message)
        consumer.commit(message)
      end
    end
  rescue => e
    Rails.logger.error "Consumer error: #{e.message}"
  ensure
    consumer&.close
  end

  def process_message(message)
    data = JSON.parse(message.payload)
    Rails.logger.info "Processing: #{data}"
    
    # Execute business logic
    case data['event_type']
    when 'user_created'
      handle_user_created(data)
    end
    
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON: #{e.message}"
  rescue => e
    Rails.logger.error "Processing error: #{e.message}"
    raise # Re-raise so the message can be retried
  end

  def graceful_shutdown
    @running = false
    Rails.logger.info "Shutting down consumer gracefully"
  end
end
```

### Launch script
```ruby
# bin/kafka_consumer
#!/usr/bin/env ruby
require_relative '../config/environment'

KafkaConsumerRunner.start
```

## Key considerations for consumers

### 1. Error handling
- Producers can log and continue.
- Consumers must enforce idempotency and implement retries.

### 2. Offset management
```ruby
# Guarantee completion with manual commits
consumer.each do |message|
  begin
    process_message(message)
    consumer.commit(message) # Commit only after success
  rescue => e
    Rails.logger.error "Processing failed: #{e.message}"
    # Skip commit on failure to allow reprocessing
  end
end
```

### 3. Idempotency
```ruby
def process_message(message)
  message_id = extract_message_id(message)
  
  return if already_processed?(message_id)
  
  begin
    perform_business_logic(message)
    mark_as_processed(message_id)
  rescue => e
    remove_processing_mark(message_id)
    raise
  end
end
```

### 4. Handling encrypted data
```ruby
def process_encrypted_message(message)
  encryptor = ActiveRecord::Encryption.encryptor
  
  begin
    decrypted_payload = encryptor.decrypt(message.payload)
    process_decrypted_data(JSON.parse(decrypted_payload))
  rescue ActiveRecord::Encryption::Errors::Decryption => e
    Rails.logger.error "Decryption failed: #{e.message}"
    # Route to a dead-letter queue
  end
end
```

## Deploying on Kubernetes

### Sample Deployment manifest
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kafka-consumer
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kafka-consumer
  template:
    metadata:
      labels:
        app: kafka-consumer
    spec:
      containers:
      - name: kafka-consumer
        image: your-rails-app:latest
        command: ["bundle", "exec", "ruby", "bin/kafka_consumer"]
        env:
        - name: KAFKA_BOOTSTRAP_SERVERS
          value: "kafka:9092"
        - name: RAILS_ENV
          value: "production"
        resources:
          requests:
            memory: "256Mi"
            cpu: "250m"
          limits:
            memory: "512Mi"
            cpu: "500m"
```

## Best practices

### Producer
- Keep error handling simple (log and continue).
- Allow failures when the event is non-critical.
- Optimise for throughput.

### Consumer
- Commit offsets manually.
- Guarantee idempotency.
- Implement graceful shutdown.
- Use a dead-letter queue.
- Add monitoring and health checks.

### Security
- Encrypt with ActiveRecord::Encryption.
- Send sensitive data only after encryption.
- Decrypt safely on the consumer side.

## Dependencies
```ruby
# Gemfile
gem 'rdkafka', '~> 0.21.0'  # ruby-kafka is EOL, use rdkafka instead
```

## How to run
```bash
# Producer (Rails Console)
rails console

# Consumer
bundle exec ruby bin/kafka_consumer

# Or via a Rake task
bundle exec rake kafka:consumer
```
