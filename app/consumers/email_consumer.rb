# frozen_string_literal: true

# Email consumer for processing email sending jobs from Kafka
class EmailConsumer < ApplicationConsumer
  def consume
    # Process messages from Kafka
    # Expected payload format: JSON with { mailer_class: "MailerClassName", params: {...} }
    messages.each do |message|
      process_email_message(message)
    rescue StandardError => e
      Rails.logger.error "Failed to process email message: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Consider adding dead letter queue handling here
    end
  end

  private

  def process_email_message(message)
    # Parse JSON payload (safer than Marshal.load)
    payload = JSON.parse(message.raw_payload)

    mailer_class = payload["mailer_class"]
    mailer_action = payload["mailer_action"] || "create"
    params = payload["params"] || {}

    # Validate mailer class exists and is allowed
    unless valid_mailer?(mailer_class)
      Rails.logger.error "Invalid mailer class: #{mailer_class}"
      return
    end

    # Convert string keys to symbols for ActionMailer params
    symbolized_params = params.transform_keys(&:to_sym)

    # Decrypt params if needed
    # decrypted_params = symbolized_params.transform_values { |v| decrypt(v) }

    # Send email
    mailer = mailer_class.constantize
    mailer.with(symbolized_params).public_send(mailer_action).deliver_now

    Rails.logger.info "Email sent via #{mailer_class}##{mailer_action} with params: #{params.keys}"
  end

  def valid_mailer?(mailer_class)
    # Whitelist of allowed mailer classes to prevent code injection
    allowed_mailers = [
      "Email::App::RegistrationMailer",
      "Email::Org::RegistrationMailer"
      # Add other allowed mailers here
    ]

    allowed_mailers.include?(mailer_class)
  end

  # Run anything upon partition being revoked
  # def revoked
  # end

  # Define here any teardown things you want when Karafka server stops
  # def shutdown
  # end
end
