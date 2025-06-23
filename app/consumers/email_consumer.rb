# frozen_string_literal: true

# Example consumer that prints messages payloads
class EmailConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      Email::App::EmailRegistrationMailer.with('email_address': message.payload['to']).create.deliver_now
    end
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
