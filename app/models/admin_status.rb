# frozen_string_literal: true

class AdminStatus < OperatorRecord
  include StringPrimaryKey

  # Status constants
  NEYO = "NEYO"
  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_status,
           dependent: :restrict_with_error
  validates :id, uniqueness: { case_sensitive: false }
end
