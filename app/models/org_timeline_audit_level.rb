class OrgTimelineAuditLevel < BusinessesRecord
  include UppercaseId

  has_many :org_timeline_audits, dependent: :restrict_with_error, inverse_of: :org_timeline_audit_level
end
