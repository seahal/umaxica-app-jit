# typed: false
# frozen_string_literal: true

class SmsDeliveryJob < ApplicationJob
  queue_as :default

  retry_on Aws::SNS::Errors::ServiceError, wait: :polynomially_longer, attempts: 5
  retry_on Net::OpenTimeout, wait: :polynomially_longer, attempts: 3
  retry_on Net::ReadTimeout, wait: :polynomially_longer, attempts: 3

  discard_on ArgumentError

  def perform(to:, message:, subject: nil)
    AwsSmsService.send_message(to: to, message: message, subject: subject)
  end
end
