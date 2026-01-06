# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_levels
#
#  id         :string           default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StaffAuditLevel < OperatorRecord
  include UppercaseId

  has_many :staff_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :staff_audit_level
end
