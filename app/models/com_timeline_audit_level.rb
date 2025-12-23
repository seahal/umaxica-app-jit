class ComTimelineAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :com_timeline_audits, dependent: :restrict_with_error, inverse_of: :com_timeline_audit_level
end
