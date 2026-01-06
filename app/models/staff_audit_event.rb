# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_audit_events
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class StaffAuditEvent < OperatorRecord
  include UppercaseId

  # Association with staff_audits
  has_many :staff_audits,
           foreign_key: :event_id,
           dependent: :destroy,
           inverse_of: :staff_audit_event
end
