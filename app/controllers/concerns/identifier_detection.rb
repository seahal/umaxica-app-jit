# typed: false
# frozen_string_literal: true

# IdentifierDetection
#
# Detects whether a user-provided identifier is an email address or telephone number,
# and looks up the user accordingly.
#
# Detection rules:
#   - Contains "@" -> email
#   - Contains "+" -> telephone (E.164 international format required)
#   - Neither -> unknown (rejected)
#
module IdentifierDetection
  extend ActiveSupport::Concern

  private

  def detect_identifier_type(identifier)
    return :unknown if identifier.blank?

    return :email if identifier.include?("@")
    return :telephone if identifier.include?("+")

    :unknown
  end

  def find_user_by_identifier(identifier)
    case detect_identifier_type(identifier.to_s.strip)
    when :email
      normalized = validate_and_normalize_email(identifier.strip)
      return nil if normalized.blank?

      bidx = IdentifierBlindIndex.bidx_for_email(normalized)
      return nil if bidx.blank?

      user = UserEmail.find_by(address_bidx: bidx)&.user
      user if user&.login_allowed?
    when :telephone
      normalized = TelephoneNormalization.normalize_to_e164(identifier.strip)
      return nil if normalized.blank?

      bidx = IdentifierBlindIndex.bidx_for_telephone(normalized)
      return nil if bidx.blank?

      user = UserTelephone.find_by(number_bidx: bidx)&.user
      user if user&.login_allowed?
    end
  end
end
