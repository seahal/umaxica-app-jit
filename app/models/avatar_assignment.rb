# == Schema Information
#
# Table name: avatar_assignments
#
#  id         :uuid             not null, primary key
#  avatar_id  :string(255)      not null
#  user_id    :uuid             not null
#  role       :string(50)       default("viewer"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_avatar_assignments_on_user_id          (user_id)
#  index_avatar_assignments_unique              (avatar_id,user_id,role) UNIQUE
#  index_avatar_assignments_unique_affiliation  (avatar_id) UNIQUE
#  index_avatar_assignments_unique_owner        (avatar_id) UNIQUE
#

# frozen_string_literal: true

class AvatarAssignment < IdentitiesRecord
  ROLES = %w(owner affiliation administrator editor reviewer viewer).freeze

  belongs_to :avatar
  belongs_to :user

  validates :role, presence: true, inclusion: { in: ROLES }, length: { maximum: 50 }
  validates :avatar_id, length: { maximum: 255 }
  validates :avatar_id, uniqueness: { scope: [:user_id, :role] }

  validates :avatar_id,
            uniqueness: { conditions: -> { where(role: "owner") } },
            if: -> { role == "owner" }

  validates :avatar_id,
            uniqueness: { conditions: -> { where(role: "affiliation") } },
            if: -> { role == "affiliation" }
end
