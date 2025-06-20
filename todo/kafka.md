# Ruby on Rails と Kafka の連携方法

## 概要
RailsアプリケーションでKafkaを利用する際の実装方法とベストプラクティス

## Producer（メッセージ送信）

### 基本的な送信方法
```ruby
# Rails Console での実行例
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

### Controller からの送信
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

### 暗号化データの送信
```ruby
# ActiveRecord::Encryption を使用
encryptor = ActiveRecord::Encryption.encryptor
encrypted_data = encryptor.encrypt("sensitive data")

producer.produce(
  topic: "encrypted-topic",
  payload: encrypted_data,
  key: "encrypted-key"
)
producer.flush
```

## Consumer（メッセージ受信）

### Rails Runner を使った Consumer 実装
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
    
    # ビジネスロジックの実行
    case data['event_type']
    when 'user_created'
      handle_user_created(data)
    end
    
  rescue JSON::ParserError => e
    Rails.logger.error "Invalid JSON: #{e.message}"
  rescue => e
    Rails.logger.error "Processing error: #{e.message}"
    raise # 再処理のためにエラーを再発生
  end

  def graceful_shutdown
    @running = false
    Rails.logger.info "Shutting down consumer gracefully"
  end
end
```

### 起動スクリプト
```ruby
# bin/kafka_consumer
#!/usr/bin/env ruby
require_relative '../config/environment'

KafkaConsumerRunner.start
```

## Consumer 設計の重要な考慮事項

### 1. エラーハンドリング
- Producer側ではシンプルにエラーログのみ
- Consumer側で冪等性と再試行を実装

### 2. オフセット管理
```ruby
# 手動コミットで処理完了を保証
consumer.each do |message|
  begin
    process_message(message)
    consumer.commit(message) # 成功時のみコミット
  rescue => e
    Rails.logger.error "Processing failed: #{e.message}"
    # 失敗時はコミットしない（再処理される）
  end
end
```

### 3. 冪等性の実装
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

### 4. 暗号化データの処理
```ruby
def process_encrypted_message(message)
  encryptor = ActiveRecord::Encryption.encryptor
  
  begin
    decrypted_payload = encryptor.decrypt(message.payload)
    process_decrypted_data(JSON.parse(decrypted_payload))
  rescue ActiveRecord::Encryption::Errors::Decryption => e
    Rails.logger.error "Decryption failed: #{e.message}"
    # デッドレターキューに送信
  end
end
```

## Kubernetes でのデプロイ

### Deployment 設定例
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

## ベストプラクティス

### Producer
- エラーハンドリングはシンプルに（ログのみ）
- 重要でない場合は失敗を許容
- パフォーマンスを重視

### Consumer
- 手動オフセットコミット
- 冪等性の確保
- Graceful shutdown の実装
- デッドレターキューの活用
- 監視・ヘルスチェックの実装

### セキュリティ
- ActiveRecord::Encryption で暗号化
- 機密データは暗号化してから送信
- Consumer側で適切に復号化

## 依存関係
```ruby
# Gemfile
gem 'rdkafka', '~> 0.21.0'  # ruby-kafka は EOL のため rdkafka を使用
```

## 実行方法
```bash
# Producer（Rails Console）
rails console

# Consumer
bundle exec ruby bin/kafka_consumer

# または Rake Task として
bundle exec rake kafka:consumer
```