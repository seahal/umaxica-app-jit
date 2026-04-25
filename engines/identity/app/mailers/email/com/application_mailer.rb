# typed: false
# frozen_string_literal: true

module Email::Com
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.app.creds.require(:SMTP_FROM_ADDRESS)
    layout "mailer/com/mailer"
  end
end
