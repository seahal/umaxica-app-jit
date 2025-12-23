class AppTimelineAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :app_timeline_audits, dependent: :restrict_with_error, inverse_of: :app_timeline_audit_level
end
