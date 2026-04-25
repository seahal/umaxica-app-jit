# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_capabilities
# Database name: avatar
#
#  id :bigint           not null, primary key
#

class AvatarCapability < AvatarRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NORMAL = 1

  has_many :avatars, foreign_key: :capability_id, inverse_of: :capability, dependent: :restrict_with_error
end
