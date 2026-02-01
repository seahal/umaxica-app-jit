# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_roles
# Database name: avatar
#
#  id          :integer          not null, primary key
#  description :text
#  key         :string           not null
#  name        :string           not null
#
# Indexes
#
#  index_avatar_roles_on_key  (key) UNIQUE
#

class AvatarRole < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_role_permissions, dependent: :restrict_with_error
  has_many :avatar_permissions, through: :avatar_role_permissions
  has_many :avatar_memberships, foreign_key: :role_id, dependent: :restrict_with_error, inverse_of: :avatar_role

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
