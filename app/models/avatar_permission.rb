# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_permissions
# Database name: avatar
#
#  id :bigint           not null, primary key
#

class AvatarPermission < AvatarRecord
  self.record_timestamps = false
  # Fixed IDs - do not modify these values
  NEYO = 1
  READ = 2
  WRITE = 3
  ADMIN = 4

  has_many :avatar_role_permissions, dependent: :restrict_with_error
  has_many :avatar_roles, through: :avatar_role_permissions
end
