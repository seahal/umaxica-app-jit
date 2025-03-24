class App::RegistrationMailer < App::ApplicationMailer
  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.app.registration_mailer.two.subject
  #
  def two
    @greeting = "Hi"

    mail to: ""
  end
end
