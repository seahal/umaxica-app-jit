# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_statuses
# Database name: operator
#
#  id :bigint           not null, primary key
#
class WorkspaceStatus < OperatorRecord
  self.record_timestamps = false

  self.primary_key = "id"
  # Fixed IDs - do not modify these values
  NEYO = 1

  has_many :workspaces, dependent: :restrict_with_error
end
