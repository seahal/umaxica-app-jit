# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_role_permissions
# Database name: avatar
#
#  id                   :bigint           not null, primary key
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  avatar_permission_id :bigint           default(0), not null
#  avatar_role_id       :bigint           default(0), not null
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
  # self.record_timestamps = false

  belongs_to :avatar_role
  belongs_to :avatar_permission

  validates :avatar_role_id, uniqueness: { scope: :avatar_permission_id }
  validates :created_at, :updated_at, presence: true
end
