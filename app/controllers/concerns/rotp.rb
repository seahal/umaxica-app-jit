# frozen_string_literal: true

module Rotp
  extend ActiveSupport::Concern

  private

  # TODO: remove this temporary email delivery helper once OTP flow is centralized.
  def send_otp_code_using_email(pass_code: nil, email_address: nil)
    raise unless pass_code
    raise unless email_address

    Email::App::ContactMailer.with({ email_address: email_address, pass_code: pass_code }).create.deliver_now
  end

  # TODO: remove this temporary SMS helper once OTP flow is centralized.
  def send_otp_code_using_sms(pass_code: nil, telephone_number: nil)
    raise unless pass_code
    raise unless telephone_number

    AwsSmsService.send_message(
      to: telephone_number,
      message: "PassCode => #{pass_code}",
      subject: "PassCode"
    )
  end

  # Generate a new HOTP secret, counter, and corresponding 6-digit pass code for one-time use.
  # All three values should be persisted together so the pass code can be verified later.
  def generate_hotp_code
    sec = ROTP::Base32.random
    hotp = ROTP::HOTP.new(sec)
    counter = rand(1...1000000) * 2
    [ sec, counter, hotp.at(counter) ]
  end

  # Verify the submitted pass code by recreating the HOTP value from the stored secret and counter.
  # Returns true only when the provided code exactly matches the expected value.
  def verify_hotp_code(secret:, counter:, pass_code:)
    hotp = ROTP::HOTP.new(secret)
    hotp.verify(pass_code, counter) == counter
  end
end
