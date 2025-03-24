# Preview all emails at http://localhost:3000/rails/mailers/app/registration_mailer
class App::RegistrationMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/app/registration_mailer/two
  def two
    App::RegistrationMailer.two
  end
end
