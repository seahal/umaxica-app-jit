# Preview all emails at http://localhost:3000/rails/mailers/email/com/service_site_contact_mailer
class Email::Com::ServiceSiteContactMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/email/com/service_site_contact_mailer/create
  delegate :create, to: :'Email::Com::ServiceSiteContactMailer'
end
