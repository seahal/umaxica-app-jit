# typed: false
# frozen_string_literal: true

# Shared refresh-token primitives for both auth and preference paths.
module RefreshTokenShared
  extend ActiveSupport::Concern

  REFRESH_TOKEN_SEPARATOR = "."
  REFRESH_VERIFIER_BYTES = 48

  class_methods do
    def refresh_token_separator
      REFRESH_TOKEN_SEPARATOR
    end

    def refresh_token_verifier_bytes
      REFRESH_VERIFIER_BYTES
    end

    def generate_refresh_token(public_id:, verifier: nil)
      verifier ||= SecureRandom.urlsafe_base64(refresh_token_verifier_bytes)
      [build_refresh_token(public_id, verifier), verifier]
    end

    def build_refresh_token(public_id, verifier)
      "#{public_id}#{refresh_token_separator}#{verifier}"
    end

    def parse_refresh_token(token)
      return nil if token.blank?

      public_id, verifier = token.split(refresh_token_separator, 2)
      return nil if public_id.blank? || verifier.blank?

      [public_id, verifier]
    end

    def digest_refresh_token(verifier)
      SHA3::Digest::SHA3_384.digest(verifier.to_s)
    end

    def legacy_refresh_token_digest(token)
      SHA3::Digest::SHA3_384.digest(token.to_s)
    end

    def secure_compare?(expected, actual)
      return false if expected.blank? || actual.blank?

      ActiveSupport::SecurityUtils.secure_compare(expected, actual)
    end
  end

  def generate_refresh_token(public_id:)
    self.class.generate_refresh_token(public_id: public_id)
  end

  delegate :parse_refresh_token, :digest_refresh_token,
           :legacy_refresh_token_digest, :secure_compare?,
           :refresh_token_separator, :refresh_token_verifier_bytes,
           to: :class
end
