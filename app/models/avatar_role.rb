# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_roles
#
#  id          :string           not null, primary key
#  key         :string           not null
#  name        :string           not null
#  description :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_avatar_roles_on_key  (key) UNIQUE
#

class AvatarRole < IdentitiesRecord
  include StringPrimaryKey

  has_many :avatar_role_permissions, dependent: :restrict_with_error
  has_many :avatar_permissions, through: :avatar_role_permissions

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
