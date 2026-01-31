# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class AvatarMembershipStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :avatar_memberships, dependent: :restrict_with_error
end
