# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_capabilities
# Database name: avatar
#
#  id          :integer          not null, primary key
#  description :text
#  key         :string           not null
#  name        :string           not null
#
# Indexes
#
#  index_avatar_capabilities_on_key  (key) UNIQUE
#

class AvatarCapability < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatars, foreign_key: :capability_id, inverse_of: :capability, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
