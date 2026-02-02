# == Schema Information
#
# Table name: organizations
# Database name: operator
#
#  id                  :bigint           not null, primary key
#  domain              :string           default(""), not null
#  name                :string           default(""), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  admin_id            :bigint
#  department_id       :bigint
#  parent_id           :bigint
#  workspace_status_id :bigint           default(0), not null
#
# Indexes
#
#  index_organizations_on_admin_id             (admin_id)
#  index_organizations_on_department_id        (department_id)
#  index_organizations_on_domain               (domain) UNIQUE
#  index_organizations_on_parent_id            (parent_id)
#  index_organizations_on_workspace_status_id  (workspace_status_id)
#
# Foreign Keys
#
#  fk_rails_...  (workspace_status_id => organization_statuses.id)
#

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
