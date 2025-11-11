module Email
  module Com
    class ContactMailer < ApplicationMailer
      def create
        @pass_code = params[:'pass_code']
        mail(
          to: params[:'email_address'],
          subject: "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - Email Verification Code"
        )
      end
    end
  end
end
