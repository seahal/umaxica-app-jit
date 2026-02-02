# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_capabilities
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_capabilities_on_code  (code) UNIQUE
#

class AvatarCapability < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatars, foreign_key: :capability_id, inverse_of: :capability, dependent: :restrict_with_error
end
