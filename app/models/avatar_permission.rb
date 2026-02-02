# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_permissions
# Database name: avatar
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_avatar_permissions_on_code  (code) UNIQUE
#

class AvatarPermission < AvatarRecord
  include CodeIdentifiable

  self.record_timestamps = false

  has_many :avatar_role_permissions, dependent: :restrict_with_error
  has_many :avatar_roles, through: :avatar_role_permissions
end
