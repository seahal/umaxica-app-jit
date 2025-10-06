module Email::Com
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.application.credentials.dig(:SMTP_FROM_ADDRESS)
    layout "mailer/com/mailer"
  end
end
