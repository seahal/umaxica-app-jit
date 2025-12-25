# == Schema Information
#
# Table name: avatar_membership_statuses
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
#  index_avatar_membership_statuses_on_key  (key) UNIQUE
#

class AvatarMembershipStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :avatar_memberships, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
