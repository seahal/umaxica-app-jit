# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id :integer          not null, primary key, limit: 2
#
class AvatarOwnershipStatus < AvatarRecord
  self.record_timestamps = false

  has_many :avatar_ownership_periods, dependent: :restrict_with_error
end
