module Email
  module App
    class ContactMailer < ApplicationMailer
      def create
        @pass_code = params[:pass_code]
        mail to: params[:email_address]
      end
    end
  end
end
