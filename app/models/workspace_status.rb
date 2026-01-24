# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_statuses
# Database name: operator
#
#  id         :string(255)      not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class WorkspaceStatus < OperatorRecord
  include StringPrimaryKey

  self.primary_key = "id"

  has_many :workspaces, dependent: :restrict_with_error
end
