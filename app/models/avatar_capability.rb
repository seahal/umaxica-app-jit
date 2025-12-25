# == Schema Information
#
# Table name: avatar_capabilities
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
#  index_avatar_capabilities_on_key  (key) UNIQUE
#

class AvatarCapability < IdentitiesRecord
  include StringPrimaryKey

  has_many :avatars, foreign_key: :capability_id, inverse_of: :capability, dependent: :restrict_with_error

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end
