# frozen_string_literal: true

module Rotp
  extend ActiveSupport::Concern

  private

  def send_otp_code_using_email(pass_code: nil, email_address: nil)
    raise unless pass_code
    raise unless email_address
    Email::App::ContactMailer.with({ email_address: email_address, pass_code: pass_code }).create.deliver_now
  end

  def send_otp_code_using_sms(pass_code: nil, telephone_number: nil)
    raise unless pass_code
    raise unless telephone_number

    SmsService.send_message(
      to: telephone_number,
      message: "PassCode => #{pass_code}",
      subject: "PassCode"
    )
  end
end
