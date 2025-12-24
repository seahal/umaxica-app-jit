# == Schema Information
#
# Table name: user_memberships
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  joined_at    :datetime         not null
#  left_at      :datetime         default("-infinity"), not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_user_memberships_on_user_id_and_workspace_id  (user_id,workspace_id) UNIQUE
#  index_user_memberships_on_workspace_id              (workspace_id)
#

class UserMembership < IdentityRecord
  belongs_to :user, class_name: "User", inverse_of: :user_memberships
  belongs_to :workspace, class_name: "Workspace", inverse_of: :user_memberships
  validates :user_id, uniqueness: { scope: :workspace_id }

  scope :active, -> { where("left_at > ?", Time.current) }
end
