module Email::App
  class RegistrationMailer < ApplicationMailer
    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.email.app.email_registration_mailer.create.subject
    #
    def create
      @greeting = params[:hotp_token]
      mail to: params[:email_address]
    end
  end
end
