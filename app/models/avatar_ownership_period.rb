# == Schema Information
#
# Table name: avatar_ownership_periods
#
#  id                         :string           not null, primary key
#  avatar_id                  :string           not null
#  owner_organization_id      :string           not null
#  valid_from                 :timestamptz      not null
#  valid_to                   :timestamptz      default("infinity"), not null
#  avatar_ownership_status_id :string
#  transferred_by_actor_id    :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
# Indexes
#
#  index_avatar_ownership_periods_on_avatar_id                   (avatar_id) UNIQUE
#  index_avatar_ownership_periods_on_avatar_ownership_status_id  (avatar_ownership_status_id)
#  index_avatar_ownership_periods_on_owner_organization_id       (owner_organization_id)
#

class AvatarOwnershipPeriod < IdentitiesRecord
  include StringPrimaryKey

  belongs_to :avatar
  belongs_to :avatar_ownership_status, optional: true

  validates :avatar_id, uniqueness: true
  validates :owner_organization_id, presence: true
  validates :valid_from, presence: true
end
