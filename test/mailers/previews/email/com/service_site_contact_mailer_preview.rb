# Preview all emails at http://localhost:3000/rails/mailers/email/com/service_site_contact_mailer
class Email::Com::ServiceSiteContactMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email/com/service_site_contact_mailer/create
  def create
    Email::Com::ServiceSiteContactMailer.create
  end
end
