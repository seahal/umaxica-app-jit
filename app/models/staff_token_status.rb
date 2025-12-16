# frozen_string_literal: true

class StaffTokenStatus < TokensRecord
  include UppercaseIdValidation

  has_many :staff_tokens, dependent: :restrict_with_error

  # Status constants
  NONE = "NONE"
end
