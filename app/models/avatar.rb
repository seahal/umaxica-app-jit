# frozen_string_literal: true

# == Schema Information
#
# Table name: avatars
#
#  id                           :string           not null, primary key
#  public_id                    :string           default(""), not null
#  moniker                      :string           not null
#  image_data                   :jsonb            default("{}"), not null
#  owner_organization_id        :string
#  representing_organization_id :string
#  active_handle_id             :string           not null
#  capability_id                :string           not null
#  avatar_status_id             :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  lock_version                 :integer          default(0), not null
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

  # Avatar assignments (role-based access control)
  has_many :avatar_assignments, dependent: :destroy

  # Single-user roles (has_one through)
  has_one :owner_assignment,
          -> { where(role: "owner") },
          class_name: "AvatarAssignment",
          inverse_of: :avatar,
          dependent: :destroy
  has_one :owner,
          through: :owner_assignment,
          source: :user

  has_one :affiliation_assignment,
          -> { where(role: "affiliation") },
          class_name: "AvatarAssignment",
          inverse_of: :avatar,
          dependent: :destroy
  has_one :affiliation_user,
          through: :affiliation_assignment,
          source: :user

  # Multi-user roles (has_many through)
  has_many :administrator_assignments,
           -> { where(role: "administrator") },
           class_name: "AvatarAssignment",
           inverse_of: :avatar,
           dependent: :destroy
  has_many :administrators,
           through: :administrator_assignments,
           source: :user

  has_many :editor_assignments,
           -> { where(role: "editor") },
           class_name: "AvatarAssignment",
           inverse_of: :avatar,
           dependent: :destroy
  has_many :editors,
           through: :editor_assignments,
           source: :user

  has_many :reviewer_assignments,
           -> { where(role: "reviewer") },
           class_name: "AvatarAssignment",
           inverse_of: :avatar,
           dependent: :destroy
  has_many :reviewers,
           through: :reviewer_assignments,
           source: :user

  has_many :viewer_assignments,
           -> { where(role: "viewer") },
           class_name: "AvatarAssignment",
           inverse_of: :avatar,
           dependent: :destroy
  has_many :viewers,
           through: :viewer_assignments,
           source: :user

  validates :public_id, presence: true, uniqueness: true
  validates :moniker, presence: true

  # Create avatar with owner assigned in a transaction
  def self.create_with_owner(attributes, user)
    transaction do
      avatar = create!(attributes)
      avatar.avatar_assignments.create!(user: user, role: "owner")
      avatar
    end
  end
end
