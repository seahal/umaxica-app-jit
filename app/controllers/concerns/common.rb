# frozen_string_literal: true

module Common
  extend ActiveSupport::Concern

  private

  # generate uuid
  def gen_original_uuid
    SecureRandom.uuid_v7
  end

  # convert utc to local time
  def localize_time(time, _zone = "Tokyo")
    time.in_time_zone("Tokyo")
  end

  # text encryption using ActiveRecord encryption
  def text_encryption(text)
    ActiveRecord::Encryption.encryptor.encrypt(text)
  end
end
