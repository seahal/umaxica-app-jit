# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_memberships
# Database name: avatar
#
#  id                          :bigint           not null, primary key
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default(Infinity), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  actor_id                    :string           not null
#  avatar_id                   :bigint           not null
#  avatar_membership_status_id :bigint
#  granted_by_actor_id         :string
#  role_id                     :bigint           default(0), not null
#
# Indexes
#
#  index_avatar_memberships_on_actor_id                     (actor_id) WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_avatar_memberships_on_avatar_id_and_actor_id       (avatar_id,actor_id) UNIQUE WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_avatar_memberships_on_avatar_membership_status_id  (avatar_membership_status_id)
#  index_avatar_memberships_on_role_id                      (role_id)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#  fk_rails_...  (avatar_membership_status_id => avatar_membership_statuses.id)
#  fk_rails_...  (role_id => avatar_roles.id)
#

class AvatarMembership < AvatarRecord
  belongs_to :avatar
  belongs_to :avatar_membership_status, optional: true
  belongs_to :avatar_role, foreign_key: :role_id, inverse_of: :avatar_memberships

  validates :avatar_id, uniqueness: { scope: :actor_id }
  validates :actor_id, presence: true
  validates :valid_from, presence: true
  validates :id, length: { maximum: 255 }
end
