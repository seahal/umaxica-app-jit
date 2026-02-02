# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_membership_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_membership_statuses_on_code  (code) UNIQUE
#
class AvatarMembershipStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_memberships, dependent: :restrict_with_error
end
