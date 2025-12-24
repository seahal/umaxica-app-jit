# == Schema Information
#
# Table name: user_identity_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserIdentityAuditLevel < IdentityRecord
  include UppercaseId

  has_many :user_identity_audits, dependent: :restrict_with_error, inverse_of: :user_identity_audit_level
end
