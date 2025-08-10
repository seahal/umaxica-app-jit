# delable

class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome_email
  delegate :welcome_email, to: :UserMailer
end
