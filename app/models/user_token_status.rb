class UserTokenStatus < TokensRecord
  include UppercaseId

  has_many :user_tokens, dependent: :restrict_with_error

  # Status constants
  NONE = "NONE"
end
