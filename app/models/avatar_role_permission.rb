# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_role_permissions
# Database name: avatar
#
#  id                   :string           not null, primary key
#  avatar_permission_id :integer          not null, limit: 2
#  avatar_role_id       :integer          not null, limit: 2
#
# Indexes
#
#  index_avatar_role_permissions_on_avatar_permission_id  (avatar_permission_id)
#  uniq_avatar_role_permissions                           (avatar_role_id,avatar_permission_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (avatar_permission_id => avatar_permissions.id)
#  fk_rails_...  (avatar_role_id => avatar_roles.id)
#

class AvatarRolePermission < AvatarRecord
  self.record_timestamps = false

  belongs_to :avatar_role
  belongs_to :avatar_permission

  validates :avatar_role_id, presence: true
  validates :avatar_permission_id, presence: true
  validates :avatar_role_id, uniqueness: { scope: :avatar_permission_id }
end
