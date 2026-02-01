# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id :integer          not null, primary key
#
# Indexes
#
#  index_avatar_membership_statuses_on_id  (id) UNIQUE
#
class AvatarMembershipStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_memberships, dependent: :restrict_with_error
end
