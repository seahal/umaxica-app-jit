# frozen_string_literal: true

# == Schema Information
#
# Table name: app_timeline_audit_levels
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class AppTimelineAuditLevel < UniversalRecord
  include UppercaseId

  has_many :app_timeline_audits, dependent: :restrict_with_error, inverse_of: :app_timeline_audit_level
end
