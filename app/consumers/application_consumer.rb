# frozen_string_literal: true

# Application consumer from which all Karafka consumers should inherit
# You can rename it if it would conflict with your current code base (in case you're integrating
# Karafka with other frameworks)
class ApplicationConsumer < Karafka::BaseConsumer

  private
  def decrypt(encrypted)
    ActiveRecord::Encryption.encryptor.decrypt(encrypted)
  end
end
