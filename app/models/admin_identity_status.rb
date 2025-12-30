# == Schema Information
#
# Table name: admin_identity_statuses
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class AdminIdentityStatus < IdentitiesRecord
  include UppercaseId

  has_many :admins,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :admin_identity_status

  # Status constants
  NEYO = "NEYO"
end
