# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_audit_events
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserIdentityAuditEvent < UniversalRecord
  include UppercaseId

  # Association with user_identity_audits
  has_many :user_identity_audits,
           foreign_key: :event_id,
           dependent: :restrict_with_error,
           inverse_of: :user_identity_audit_event
end
