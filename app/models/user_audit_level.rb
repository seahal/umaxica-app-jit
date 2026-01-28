# frozen_string_literal: true

# == Schema Information
#
# Table name: user_audit_levels
# Database name: audit
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :user_audits,
           foreign_key: :level_id,
           dependent: :restrict_with_error,
           inverse_of: :user_audit_level
end
