# == Schema Information
#
# Table name: com_timeline_audit_levels
#
#  id         :string           default("NONE"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ComTimelineAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :com_timeline_audits, dependent: :restrict_with_error, inverse_of: :com_timeline_audit_level
end
