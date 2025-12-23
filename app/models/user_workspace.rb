class UserWorkspace < IdentityRecord
  belongs_to :user, class_name: "User", inverse_of: :user_workspaces
  belongs_to :workspace, class_name: "Workspace", inverse_of: :user_workspaces
end
