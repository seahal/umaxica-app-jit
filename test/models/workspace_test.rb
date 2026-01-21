# frozen_string_literal: true

require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  test "should be valid" do
    workspace = Workspace.new(
      name: "Test Workspace",
      domain: "test-workspace",
    )
    assert_predicate workspace, :valid?
  end

  test "should inherit from Organization" do
    assert_equal "organizations", Workspace.table_name
    assert_operator Workspace, :<, Organization
  end
end
