# frozen_string_literal: true

module SecureOtpStorage
  extend ActiveSupport::Concern

  private

  # Stores OTP secrets in Redis instead of session (cookie)
  # OTP secrets should NEVER be stored in cookies
  def store_otp_secret(id, address, otp_private_key, otp_counter, expires_at)
    otp_data = {
      id: id,
      address: address,
      otp_private_key: otp_private_key,
      otp_counter: otp_counter,
      expires_at: expires_at
    }

    # Store in Redis with TTL (expires in 12 minutes)
    ttl_seconds = (expires_at - Time.now.to_i).abs
    Redis.current.setex(otp_key(id), ttl_seconds, otp_data.to_json)

    # Only store reference ID in session (safe for cookies)
    id
  end

  # Retrieves OTP secret from Redis
  def get_otp_secret(id)
    data = Redis.current.get(otp_key(id))
    return nil if data.nil?

    JSON.parse(data, symbolize_keys: true)
  end

  # Deletes OTP secret after verification
  def delete_otp_secret(id)
    Redis.current.del(otp_key(id))
  end

  # Generates unique key for Redis
  def otp_key(id)
    "otp:authentication:#{id}"
  end
end
