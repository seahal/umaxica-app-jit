module Email::App
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.application.credentials.SMTP_FROM_ADDRESS
    layout "mailer"
  end
end
