# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id :string           not null, primary key
#
class AvatarOwnershipStatus < AvatarRecord
  include StringPrimaryKey

  self.record_timestamps = false

  has_many :avatar_ownership_periods, dependent: :restrict_with_error
end
