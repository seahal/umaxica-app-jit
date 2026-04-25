# typed: false
# frozen_string_literal: true

require "openssl"

module IdentifierBlindIndex
  module_function

  def normalize_email(value)
    Jit::Utils::EmailValidator.normalize(value)
  end

  def normalize_telephone(value)
    TelephoneNormalization.normalize_to_e164(value.to_s.strip)
  end

  def bidx_for_email(value)
    normalized = normalize_email(value)
    return nil if normalized.blank?

    digest(:email, normalized)
  end

  def bidx_for_telephone(value)
    normalized = normalize_telephone(value)
    return nil if normalized.blank?

    digest(:telephone, normalized)
  end

  def digest(kind, normalized_identifier)
    OpenSSL::HMAC.hexdigest("SHA256", secret, "#{kind}:#{normalized_identifier}")
  end

  def secret
    Rails.app.creds.option(:IDENTIFIER_BIDX_SECRET) ||
      Rails.application.secret_key_base
  end
end
