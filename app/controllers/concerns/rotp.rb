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
    # FIXME: use kafka!
    Aws::SNS::Client.new(
      access_key_id: Rails.application.credentials.AWS.ACCESS_KEY_ID,
      secret_access_key: Rails.application.credentials.AWS.SECRET_ACCESS_KEY,
      region: "ap-northeast-1"
    ).publish({
                phone_number: telephone_number,
                message: "PassCode => #{pass_code}",
                subject: "PassCode"
              })
  end
end
