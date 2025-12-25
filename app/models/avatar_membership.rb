# == Schema Information
#
# Table name: avatar_memberships
#
#  id                          :string           not null, primary key
#  avatar_id                   :string           not null
#  actor_id                    :string           not null
#  role_id                     :string           not null
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default("infinity"), not null
#  avatar_membership_status_id :string
#  granted_by_actor_id         :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_avatar_memberships_on_actor_id                     (actor_id)
#  index_avatar_memberships_on_avatar_id                    (avatar_id)
#  index_avatar_memberships_on_avatar_id_and_actor_id       (avatar_id,actor_id) UNIQUE
#  index_avatar_memberships_on_avatar_membership_status_id  (avatar_membership_status_id)
#

class AvatarMembership < IdentitiesRecord
  include StringPrimaryKey

  belongs_to :avatar
  belongs_to :avatar_membership_status, optional: true
end
