module Email::App
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.application.credentials.dig(:SMTP_FROM_ADDRESS)
    layout "mailer/app/mailer"
  end
end
