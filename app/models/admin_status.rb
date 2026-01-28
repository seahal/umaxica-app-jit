# frozen_string_literal: true

# == Schema Information
#
# Table name: admin_statuses
# Database name: operator
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_admin_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
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
