# frozen_string_literal: true

# Example consumer that prints messages payloads
class EmailConsumer < ApplicationConsumer
  def consume
    #  Karafka.producer.produce_sync(topic: 'email', payload: Marshal.dump({mailer: Email::App::RegistrationMailer, params: {abc: "abc", efg: "efg"}.transform_values{ encrypt(it) } }) )
    #  {email_address: "", pass_code: "1234"}.transform_values{ encrypt(it) }
    messages.each do |message|
      # get from kafka over karafka
      pp var = Marshal.load(message.raw_payload)
      # decrypt
      pp params = var.params.transform_values{ decrypt(it) }
      # send mail
      pp var.mailer.with(params).create.deliver_now
    end
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end

  private
  def decrypt(encrypted)
    ActiveRecord::Encryption.encryptor.decrypt(encrypted)
  end
end
