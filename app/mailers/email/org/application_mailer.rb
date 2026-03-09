# typed: false
# frozen_string_literal: true

module Email::Org
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.app.creds.require(:SMTP_FROM_ADDRESS)
    layout "mailer/org/mailer"
  end
end
