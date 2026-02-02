# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_ownership_statuses
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_ownership_statuses_on_code  (code) UNIQUE
#
class AvatarOwnershipStatus < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_ownership_periods, dependent: :restrict_with_error
end
