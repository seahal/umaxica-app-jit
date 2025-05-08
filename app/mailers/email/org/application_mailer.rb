module Email::Org
  class ApplicationMailer < ActionMailer::Base
    default from: Rails.application.credentials.SMTP_FROM_ADDRESS
    layout "mailer/org/mailer"
  end
end
