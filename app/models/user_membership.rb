class UserMembership < IdentityRecord
  belongs_to :user, class_name: "User", inverse_of: :user_memberships
  belongs_to :workspace, class_name: "Workspace", inverse_of: :user_memberships

  scope :active, -> { where(left_at: nil) }
end
