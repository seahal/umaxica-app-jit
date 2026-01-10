# frozen_string_literal: true

class AdminStatus < OperatorRecord
  include StringPrimaryKey

  validates :id, uniqueness: { case_sensitive: false }

  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_status,
           dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"
end
