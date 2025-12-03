module Email
  module Com
    class ContactTelephoneMailer < ApplicationMailer
      def verify
        @pass_code = params[:pass_code]
        mail(
          to: params[:email_address],
          subject: "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - Telephone Verification Code"
        )
      end
    end
  end
end
