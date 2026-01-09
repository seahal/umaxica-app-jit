# frozen_string_literal: true

class AdminStatus < OperatorRecord
  include StringPrimaryKey

  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_status,
           dependent: :restrict_with_error

  # Status constants
  NEYO = "NEYO"
end
