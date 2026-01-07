# == Schema Information
#
# Table name: app_preference_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class AppPreferenceAuditLevel < AuditRecord
  include UppercaseId

  has_many :app_preference_audits, dependent: :restrict_with_error, inverse_of: :app_preference_audit_level
end
