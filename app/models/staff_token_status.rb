class StaffTokenStatus < TokensRecord
  include UppercaseId

  has_many :staff_tokens, dependent: :restrict_with_error

  # Status constants
  NONE = "NONE"
end
