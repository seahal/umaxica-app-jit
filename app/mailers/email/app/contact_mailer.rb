module Email
  module App
    class ContactMailer < ApplicationMailer
      def create
        @greeting = "Hi"
        mail to: params[:'email_address']
      end
    end
  end
end
