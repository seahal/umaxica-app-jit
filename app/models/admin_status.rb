# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id :string           not null, primary key
#
class AdminStatus < OperatorRecord
  include CodeIdentifiable

  # Status constants
  NEYO = "NEYO"
  has_many :admins,
           foreign_key: :status_id,
           inverse_of: :admin_status,
           dependent: :restrict_with_error
end
