class Email::Com::EmailRegistrationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.email.com.email_registration_mailer.User.subject
  #
  def User
    @greeting = "Hi"

    mail to: "to@example.org"
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.email.com.email_registration_mailer.send.subject
  #
  def send
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
