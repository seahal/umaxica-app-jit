# Preview all emails at http://localhost:3000/rails/mailers/email/app/service_site_contact_mailer
class Email::App::ServiceSiteContactMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email/app/service_site_contact_mailer/create
  def create
    Email::App::ServiceSiteContactMailer.create
  end
end
