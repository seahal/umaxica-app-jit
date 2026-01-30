# frozen_string_literal: true

# == Schema Information
#
# Table name: avatar_memberships
# Database name: avatar
#
#  id                          :string           not null, primary key
#  valid_from                  :timestamptz      not null
#  valid_to                    :timestamptz      default(Infinity), not null
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  actor_id                    :string           not null
#  avatar_id                   :string           not null
#  avatar_membership_status_id :string
#  granted_by_actor_id         :string
#  role_id                     :string           not null
#
# Indexes
#
#  index_avatar_memberships_on_actor_id                     (actor_id) WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_avatar_memberships_on_avatar_id_and_actor_id       (avatar_id,actor_id) UNIQUE WHERE (valid_to = 'infinity'::timestamp with time zone)
#  index_avatar_memberships_on_avatar_membership_status_id  (avatar_membership_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (avatar_id => avatars.id)
#  fk_rails_...  (avatar_membership_status_id => avatar_membership_statuses.id)
#

class AvatarMembership < AvatarRecord
  belongs_to :avatar
  belongs_to :avatar_membership_status, optional: true

  validates :avatar_id, uniqueness: { scope: :actor_id }
  validates :actor_id, presence: true
  validates :role_id, presence: true
  validates :valid_from, presence: true
  validates :id, length: { maximum: 255 }
end
