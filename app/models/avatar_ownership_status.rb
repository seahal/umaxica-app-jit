# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id :bigint           not null, primary key
#
class AvatarOwnershipStatus < AvatarRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1
  ACTIVE = 2
  INACTIVE = 3
  DELETED = 4

  has_many :avatar_ownership_periods, dependent: :restrict_with_error
end
