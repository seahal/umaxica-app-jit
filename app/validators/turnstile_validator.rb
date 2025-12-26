# frozen_string_literal: true

class TurnstileValidator < ActiveModel::Validator
  def validate(record)
    return unless record.turnstile_required?

    result = record.class.verify_turnstile(
      turnstile_response: record.turnstile_response,
      remote_ip: record.turnstile_remote_ip,
    )

    record.instance_variable_set(:@turnstile_result, result)

    return if result["success"]

    record.errors.add(:base, record.turnstile_error_message)
  end
end
