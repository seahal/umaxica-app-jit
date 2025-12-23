module Email
  module Org
    class TopicMailer < ApplicationMailer
      def notice
        @contact = params.fetch(:contact)
        @topic = params.fetch(:topic)
        mail(
          to: params.fetch(:email_address),
          subject: "#{ENV.fetch('BRAND_NAME', 'Umaxica')} - We received your inquiry"
        )
      end
    end
  end
end
