# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id :integer          not null, primary key, limit: 2
#
class AvatarMembershipStatus < AvatarRecord
  self.record_timestamps = false

  has_many :avatar_memberships, dependent: :restrict_with_error
end
