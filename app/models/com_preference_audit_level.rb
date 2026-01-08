# == Schema Information
#
# Table name: com_preference_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class ComPreferenceAuditLevel < AuditRecord
  include StringPrimaryKey

  has_many :com_preference_audits, dependent: :restrict_with_error, inverse_of: :com_preference_audit_level
end
