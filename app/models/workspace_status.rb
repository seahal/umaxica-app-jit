# frozen_string_literal: true

# == Schema Information
#
# Table name: workspace_statuses
# Database name: operator
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_workspace_statuses_on_code  (code) UNIQUE
#
class WorkspaceStatus < OperatorRecord
  include CodeIdentifiable

  self.record_timestamps = false

  self.primary_key = "id"

  has_many :workspaces, dependent: :restrict_with_error
end
