# frozen_string_literal: true

class UserTokenStatus < TokensRecord
  include UppercaseIdValidation

  has_many :user_tokens, dependent: :restrict_with_error

  # Status constants
  NONE = "NONE"
end
