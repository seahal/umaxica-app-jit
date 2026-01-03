# frozen_string_literal: true

# == Schema Information
#
# Table name: com_timeline_audit_levels
#
#  id :string(255)      default("NEYO"), not null, primary key
#

class ComTimelineAuditLevel < UniversalRecord
  include UppercaseId

  has_many :com_timeline_audits, dependent: :restrict_with_error, inverse_of: :com_timeline_audit_level
end
