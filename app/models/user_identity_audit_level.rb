# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserIdentityAuditLevel < UniversalRecord
  include UppercaseId

  has_many :user_identity_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_identity_audit_level
end
