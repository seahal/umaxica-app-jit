# == Schema Information
#
# Table name: avatars
#
#  id                           :string           not null, primary key
#  public_id                    :string           not null
#  moniker                      :string           not null
#  image_data                   :jsonb            default("{}"), not null
#  owner_organization_id        :string
#  representing_organization_id :string
#  active_handle_id             :string           not null
#  capability_id                :string           not null
#  avatar_status_id             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#
# Indexes
#
#  index_avatars_on_active_handle_id              (active_handle_id)
#  index_avatars_on_capability_id                 (capability_id)
#  index_avatars_on_owner_organization_id         (owner_organization_id)
#  index_avatars_on_public_id                     (public_id) UNIQUE
#  index_avatars_on_representing_organization_id  (representing_organization_id)
#

class Avatar < IdentitiesRecord
  include StringPrimaryKey
  include PublicId

  belongs_to :capability, class_name: "AvatarCapability"
  belongs_to :active_handle, class_name: "Handle"

  has_many :handle_assignments, dependent: :restrict_with_error
  has_many :handles, through: :handle_assignments
  has_many :avatar_monikers, dependent: :restrict_with_error
  has_many :avatar_memberships, dependent: :restrict_with_error
  has_many :avatar_ownership_periods, dependent: :restrict_with_error
  has_many :posts, foreign_key: :author_avatar_id, dependent: :restrict_with_error, inverse_of: :author_avatar

  validates :public_id, presence: true, uniqueness: true
  validates :moniker, presence: true
end
