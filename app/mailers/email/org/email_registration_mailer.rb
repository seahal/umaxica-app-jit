class Email::Org::EmailRegistrationMailer < ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.email.org.email_registration_mailer.create.subject
  #
  def create
    @greeting = "Hi"

    mail to: "to@example.org"
  end
end
