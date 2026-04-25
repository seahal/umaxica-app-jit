# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_statuses
# Database name: guest
#
#  id :bigint           not null, primary key
#
class OrgContactStatus < GuestRecord
  # Normal states
  NOTHING = 0      # Initial state
  COMPLETED = 1    # Successfully completed

  # Error/non-normal states (2+)
  FAILED = 2           # Processing failed
  SPAM_DETECTED = 3    # Spam detected
  PENDING_REVIEW = 4   # Pending manual review

  has_many :org_contacts,
           foreign_key: :status_id,
           inverse_of: :org_contact_status,
           dependent: :nullify
end
