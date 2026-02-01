# frozen_string_literal: true

class StaffIdentityStatus < OperatorRecord
  include CodeIdentifiable

  NEYO = "NEYO"
  ACTIVE = "ACTIVE"
  INACTIVE = "INACTIVE"
end
