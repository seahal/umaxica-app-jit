# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_role_permissions
#
#  id                   :string           not null, primary key
#  avatar_role_id       :string           not null
#  avatar_permission_id :string           not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_avatar_role_permissions_on_avatar_permission_id  (avatar_permission_id)
#  uniq_avatar_role_permissions                           (avatar_role_id,avatar_permission_id) UNIQUE
#

class AvatarRolePermission < IdentitiesRecord
  include StringPrimaryKey

  belongs_to :avatar_role
  belongs_to :avatar_permission

  validates :avatar_role_id, uniqueness: { scope: :avatar_permission_id }
end
