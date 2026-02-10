# frozen_string_literal: true

class SmsDeliveryJob < ApplicationJob
  queue_as :default

  def perform(to:, message:, subject: nil)
    AwsSmsService.send_message(to: to, message: message, subject: subject)
  end
end
