# frozen_string_literal: true

# == Schema Information
#
# Table name: user_workspaces
#
#  id           :uuid             not null, primary key
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  user_id      :uuid             not null
#  workspace_id :uuid             not null
#
# Indexes
#
#  index_user_workspaces_on_user_id       (user_id)
#  index_user_workspaces_on_workspace_id  (workspace_id)
#

class UserWorkspace < IdentitiesRecord
  belongs_to :user, class_name: "User", inverse_of: :user_workspaces
  belongs_to :workspace, class_name: "Workspace", inverse_of: :user_workspaces
end
