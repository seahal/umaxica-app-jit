# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_statuses
# Database name: operator
#
#  id :string           not null, primary key
#
class WorkspaceStatus < OperatorRecord
  include CodeIdentifiable

  self.record_timestamps = false

  self.primary_key = "id"

  has_many :workspaces, dependent: :restrict_with_error
end
