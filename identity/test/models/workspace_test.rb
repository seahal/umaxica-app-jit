# typed: false
# == Schema Information
#
# Table name: workspaces
# Database name: operator
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "should be valid" do
    workspace = Workspace.new(
      name: "Test Workspace",
    )

    assert_predicate workspace, :valid?
  end

  test "uses the workspaces table" do
    assert_equal "workspaces", Workspace.table_name
    assert_not_operator Workspace, :<, Organization
  end
end
