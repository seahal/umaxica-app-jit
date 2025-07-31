# Ruby on Rails と Kafka 連携時の暗号化

## 概要
Rails アプリケーションで Kafka を使用する際の暗号化実装方法とセキュリティ考慮事項

## ActiveRecord::Encryption の活用

### 基本的な暗号化・復号化
```ruby
# Rails での暗号化・復号化の基本形
encryptor = ActiveRecord::Encryption.encryptor

# 暗号化
encrypted_data = encryptor.encrypt("sensitive data")

# 復号化
decrypted_data = encryptor.decrypt(encrypted_data)
```

### ActiveRecord::Encryption の安全性
- **暗号化アルゴリズム**: AES-256-GCM を使用
- **認証機能**: 内蔵されたintegrity checking
- **キー管理**: Rails の設定で統一管理
- **メンテナンス**: Rails core チームが保守

## Controller 層での暗号化

### 適切性の判断
ActiveRecord::Encryption.encryptor をコントローラー層で使用することは**適切**です。

**理由:**
- 汎用的な暗号化APIを提供
- データベース専用ではない
- アプリケーション全体で一貫した暗号化方式を使用可能
- Rails 7+ で標準提供、キー管理も統合済み

### Controller での実装例
```ruby
class SensitiveDataController < ApplicationController
  def create
    encryptor = ActiveRecord::Encryption.encryptor
    
    # コントローラーで暗号化
    encrypted_payload = encryptor.encrypt(params[:sensitive_data])
    
    # Kafka に暗号化データを送信
    send_encrypted_to_kafka(encrypted_payload)
    
    # レスポンス用に復号（必要に応じて）
    decrypted_for_response = encryptor.decrypt(encrypted_payload)
    
    render json: { status: 'processed', data: decrypted_for_response }
  end

  private

  def send_encrypted_to_kafka(encrypted_data)
    config = Rdkafka::Config.new({
      "bootstrap.servers" => "127.0.0.1:9092",
      "client.id" => "encrypted-producer"
    })
    producer = config.producer
    
    producer.produce(
      topic: "encrypted_data",
      payload: encrypted_data,  # 既に暗号化済み
      headers: { "encrypted" => "true", "encryption_method" => "activerecord" }
    )
    producer.flush
    
  rescue Rdkafka::RdkafkaError => e
    Rails.logger.error "Encrypted message delivery failed: #{e.message}"
    
  ensure
    producer&.close
  end
end
```

## Kafka Producer での暗号化

### 送信前の暗号化
```ruby
class EncryptedKafkaProducer
  class << self
    def produce_encrypted(topic:, data:, key: nil, headers: {})
      encryptor = ActiveRecord::Encryption.encryptor
      
      # データを暗号化
      encrypted_payload = encryptor.encrypt(data.to_json)
      
      # 暗号化フラグをヘッダーに追加
      encrypted_headers = headers.merge({
        "encrypted" => "true",
        "encryption_method" => "activerecord",
        "content_type" => "application/json"
      })
      
      config = Rdkafka::Config.new(kafka_config)
      producer = config.producer
      
      producer.produce(
        topic: topic,
        payload: encrypted_payload,
        key: key,
        headers: encrypted_headers
      )
      producer.flush
      
    rescue Rdkafka::RdkafkaError => e
      Rails.logger.error "Encrypted Kafka delivery failed: #{e.message}"
      
    ensure
      producer&.close
    end

    private

    def kafka_config
      {
        "bootstrap.servers" => ENV.fetch("KAFKA_BOOTSTRAP_SERVERS", "127.0.0.1:9092"),
        "client.id" => "encrypted-producer"
      }
    end
  end
end
```

### 使用例
```ruby
# 暗号化してKafkaに送信
EncryptedKafkaProducer.produce_encrypted(
  topic: "user_sensitive_data",
  data: {
    user_id: user.id,
    email: user.email,
    credit_card: user.credit_card_number
  },
  key: user.id.to_s
)
```

## Kafka Consumer での復号化

### 受信時の復号化
```ruby
class EncryptedKafkaConsumer
  def process_message(message)
    # ヘッダーで暗号化確認
    if encrypted_message?(message)
      decrypt_and_process(message)
    else
      process_plain_message(message)
    end
  end

  private

  def encrypted_message?(message)
    message.headers&.dig("encrypted") == "true"
  end

  def decrypt_and_process(message)
    begin
      encryptor = ActiveRecord::Encryption.encryptor
      
      # 暗号化データを復号
      decrypted_payload = encryptor.decrypt(message.payload)
      data = JSON.parse(decrypted_payload)
      
      Rails.logger.info "Processing encrypted message: #{data.keys}"
      process_business_logic(data)
      
    rescue ActiveRecord::Encryption::Errors::Decryption => e
      Rails.logger.error "Decryption failed: #{e.message}"
      handle_decryption_failure(message, e)
      
    rescue JSON::ParserError => e
      Rails.logger.error "JSON parsing failed after decryption: #{e.message}"
      handle_parsing_failure(message, e)
    end
  end

  def handle_decryption_failure(message, error)
    # 復号化失敗時の処理
    Rails.logger.error "Message decryption failed, sending to dead letter queue"
    send_to_dead_letter_queue(message, error)
  end

  def process_business_logic(data)
    # 復号化されたデータでビジネスロジックを実行
    case data['event_type']
    when 'sensitive_user_data'
      handle_sensitive_user_data(data)
    end
  end
end
```

## 暗号化レベルの設計

### 多層暗号化アプローチ
```ruby
class MultiLayerEncryption
  def self.encrypt_for_kafka(data)
    encryptor = ActiveRecord::Encryption.encryptor
    
    # 1. アプリケーション層での暗号化
    app_encrypted = encryptor.encrypt(data.to_json)
    
    # 2. 必要に応じて追加の暗号化層
    # final_encrypted = additional_encrypt(app_encrypted)
    
    app_encrypted
  end

  def self.decrypt_from_kafka(encrypted_data)
    encryptor = ActiveRecord::Encryption.encryptor
    
    # 暗号化の逆順で復号化
    # app_encrypted = additional_decrypt(encrypted_data)
    decrypted_json = encryptor.decrypt(encrypted_data)
    
    JSON.parse(decrypted_json)
  end
end
```

## セキュリティ考慮事項

### 1. キー管理
```ruby
# config/credentials.yml.enc または環境変数
# ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
# ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
# ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
```

### 2. 暗号化対象データの選別
```ruby
def should_encrypt?(data_type)
  sensitive_types = %w[
    credit_card
    ssn
    personal_info
    medical_record
    financial_data
  ]
  
  sensitive_types.include?(data_type)
end
```

### 3. メタデータの保護
```ruby
# ヘッダーに機密情報を含めない
headers = {
  "encrypted" => "true",
  "encryption_method" => "activerecord",
  # "user_id" => user.id  # NG: 機密情報をヘッダーに含めない
}
```

## エラーハンドリング

### 暗号化失敗時の対応
```ruby
def safe_encrypt_and_send(data)
  begin
    encrypted_data = ActiveRecord::Encryption.encryptor.encrypt(data.to_json)
    send_to_kafka(encrypted_data)
    
  rescue ActiveRecord::Encryption::EncryptingError => e
    Rails.logger.error "Encryption failed: #{e.message}"
    # 暗号化失敗時は送信しない
    raise
    
  rescue JSON::GeneratorError => e
    Rails.logger.error "JSON generation failed: #{e.message}"
    raise
  end
end
```

### 復号化失敗時の対応
```ruby
def safe_decrypt_and_process(message)
  begin
    decrypted_data = ActiveRecord::Encryption.encryptor.decrypt(message.payload)
    process_data(JSON.parse(decrypted_data))
    
  rescue ActiveRecord::Encryption::Errors::Decryption => e
    Rails.logger.error "Decryption failed: #{e.message}"
    send_to_dead_letter_queue(message, e)
    
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parsing failed: #{e.message}"
    send_to_dead_letter_queue(message, e)
  end
end
```

## パフォーマンス考慮事項

### 暗号化オーバーヘッド
- **CPU使用量**: AES-256-GCM による計算コスト
- **メッセージサイズ**: 暗号化によるサイズ増加
- **スループット**: 暗号化・復号化による処理時間増加

### 最適化のヒント
```ruby
# 暗号化が必要なデータのみを対象とする
def selective_encryption(data)
  sensitive_fields = %w[credit_card ssn email]
  
  encrypted_data = data.dup
  sensitive_fields.each do |field|
    if encrypted_data[field]
      encrypted_data[field] = ActiveRecord::Encryption.encryptor.encrypt(encrypted_data[field])
    end
  end
  
  encrypted_data
end
```

## まとめ

### 推奨アプローチ
1. **ActiveRecord::Encryption** を統一的に使用
2. **Controller層** での暗号化は適切
3. **ヘッダー** で暗号化状態を明示
4. **エラーハンドリング** を適切に実装
5. **選択的暗号化** でパフォーマンス最適化

### セキュリティ原則
- 機密データは必ず暗号化してから送信
- キー管理は Rails の標準機能を活用
- 復号化失敗時は適切にエラーハンドリング
- メタデータに機密情報を含めない

この暗号化アプローチにより、Rails と Kafka の連携において高いセキュリティレベルを維持できます。