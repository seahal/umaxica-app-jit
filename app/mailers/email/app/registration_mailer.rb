# frozen_string_literal: true

module Email::App
  class RegistrationMailer < ApplicationMailer
    layout "email/application"
    # Subject can be set in your I18n file at config/locales/en.yml
    # with the following lookup:
    #
    #   en.email.app.email_registration_mailer.create.subject
    #
    def create
      @pass_code = params[:hotp_token]
      mail(
        to: params[:email_address],
        subject: I18n.t("mail.email.app.registration_mailer.create.subject"),
      )
    end
  end
end
