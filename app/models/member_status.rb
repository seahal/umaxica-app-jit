# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: member_statuses
# Database name: principal
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_member_identity_statuses_on_lower_id  (lower((id)::text)) UNIQUE
#
class MemberStatus < PrincipalRecord
  self.record_timestamps = false

  ACTIVE = 1
  INACTIVE = 2
  PENDING = 3
  DELETED = 4
  NOTHING = 5
  has_many :members,
           foreign_key: :status_id,
           dependent: :restrict_with_error,
           inverse_of: :member_status
end
