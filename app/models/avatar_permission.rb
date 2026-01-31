# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_permissions
# Database name: avatar
#
#  id          :integer          not null, primary key, limit: 2
#  description :text
#  key         :string           not null
#  name        :string           not null
#
# Indexes
#
#  index_avatar_permissions_on_key  (key) UNIQUE
#

class AvatarPermission < AvatarRecord
  self.record_timestamps = false

  has_many :avatar_role_permissions, dependent: :restrict_with_error
  has_many :avatar_roles, through: :avatar_role_permissions

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
