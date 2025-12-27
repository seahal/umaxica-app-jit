# frozen_string_literal: true

module Email::Org
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.application.credentials.dig(:SMTP_FROM_ADDRESS)
    layout "mailer/org/mailer"
  end
end
