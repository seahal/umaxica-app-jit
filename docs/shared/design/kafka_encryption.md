# Encrypting Data for Ruby on Rails and Kafka

## Overview
How to apply encryption when a Rails application exchanges data with Kafka, plus security considerations.

## Using ActiveRecord::Encryption

### Basic encryption and decryption
```ruby
# Core encrypt/decrypt flow in Rails
encryptor = ActiveRecord::Encryption.encryptor

# Encrypt
encrypted_data = encryptor.encrypt("sensitive data")

# Decrypt
decrypted_data = encryptor.decrypt(encrypted_data)
```

### Why ActiveRecord::Encryption is safe
- **Algorithm**: Uses AES-256-GCM.
- **Integrity**: Built-in authentication/verification.
- **Key management**: Centralised through Rails configuration.
- **Maintenance**: Supported by the Rails core team.

## Encrypting in the controller layer

### Is it appropriate?
It is **appropriate** to use `ActiveRecord::Encryption.encryptor` from controllers.

**Reasons:**
- Provides a general-purpose encryption API.
- Not limited to database storage.
- Ensures consistent encryption across the application.
- Rails 7+ ships it as a standard feature with integrated key management.

### Example controller implementation
```ruby
class SensitiveDataController < ApplicationController
  def create
    encryptor = ActiveRecord::Encryption.encryptor
    
    # Encrypt in the controller
    encrypted_payload = encryptor.encrypt(params[:sensitive_data])
    
    # Send encrypted data to Kafka
    send_encrypted_to_kafka(encrypted_payload)
    
    # Optionally decrypt for the response
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
      payload: encrypted_data,  # Already encrypted
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

## Encrypting in the Kafka producer

### Encrypt before publishing
```ruby
class EncryptedKafkaProducer
  class << self
    def produce_encrypted(topic:, data:, key: nil, headers: {})
      encryptor = ActiveRecord::Encryption.encryptor
      
      # Encrypt the payload
      encrypted_payload = encryptor.encrypt(data.to_json)
      
      # Flag the message as encrypted
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

### Usage example
```ruby
# Encrypt and publish to Kafka
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

## Decrypting in the Kafka consumer

### Decrypt on receipt
```ruby
class EncryptedKafkaConsumer
  def process_message(message)
    # Check encryption headers
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
      
      # Decrypt the payload
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
    Rails.logger.error "Message decryption failed, sending to dead letter queue"
    send_to_dead_letter_queue(message, error)
  end

  def process_business_logic(data)
    # Run business logic on decrypted data
    case data['event_type']
    when 'sensitive_user_data'
      handle_sensitive_user_data(data)
    end
  end
end
```

## Designing encryption levels

### Multi-layer approach
```ruby
class MultiLayerEncryption
  def self.encrypt_for_kafka(data)
    encryptor = ActiveRecord::Encryption.encryptor
    
    # 1. Application-level encryption
    app_encrypted = encryptor.encrypt(data.to_json)
    
    # 2. Optional additional layers
    # final_encrypted = additional_encrypt(app_encrypted)
    
    app_encrypted
  end

  def self.decrypt_from_kafka(encrypted_data)
    encryptor = ActiveRecord::Encryption.encryptor
    
    # Decrypt in reverse order
    # app_encrypted = additional_decrypt(encrypted_data)
    decrypted_json = encryptor.decrypt(encrypted_data)
    
    JSON.parse(decrypted_json)
  end
end
```

## Security considerations

### 1. Key management
```ruby
# Store in config/credentials.yml.enc or environment variables
# ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY
# ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY
# ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT
```

### 2. Choosing what to encrypt
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

### 3. Protecting metadata
```ruby
# Never store sensitive values in headers
headers = {
  "encrypted" => "true",
  "encryption_method" => "activerecord",
  # "user_id" => user.id  # Bad: keep secrets out of headers
}
```

## Error handling

### When encryption fails
```ruby
def safe_encrypt_and_send(data)
  begin
    encrypted_data = ActiveRecord::Encryption.encryptor.encrypt(data.to_json)
    send_to_kafka(encrypted_data)
    
  rescue ActiveRecord::Encryption::EncryptingError => e
    Rails.logger.error "Encryption failed: #{e.message}"
    # Do not send when encryption fails
    raise
    
  rescue JSON::GeneratorError => e
    Rails.logger.error "JSON generation failed: #{e.message}"
    raise
  end
end
```

### When decryption fails
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

## Performance considerations

### Encryption overhead
- **CPU usage**: AES-256-GCM adds compute cost.
- **Payload size**: Ciphertext is larger than plaintext.
- **Throughput**: Encrypting and decrypting adds latency.

### Optimisation tips
```ruby
# Encrypt only what is necessary
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

## Summary

### Recommended approach
1. Use **ActiveRecord::Encryption** consistently.
2. Encrypt in the **controller layer** when appropriate.
3. Mark encrypted messages via **headers**.
4. Implement **robust error handling**.
5. Optimise by **encrypting selectively**.

### Security principles
- Always encrypt sensitive data before sending.
- Use Rails' key management facilities.
- Handle decryption failures responsibly.
- Avoid placing sensitive information in metadata.

With this encryption strategy you can keep the Rails ⇄ Kafka integration secure.
