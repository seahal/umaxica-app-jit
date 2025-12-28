# frozen_string_literal: true

# == Schema Information
#
# Table name: workspaces
#
#  id                  :uuid             not null, primary key
#  name                :string           default(""), not null
#  domain              :string           default(""), not null
#  parent_organization :uuid             default("00000000-0000-0000-0000-000000000000"), not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
# Indexes
#
#  index_workspaces_on_domain               (domain) UNIQUE
#  index_workspaces_on_parent_organization  (parent_organization)
#

require "test_helper"

class WorkspaceTest < ActiveSupport::TestCase
  setup do
    # Ensure root workspace exists for parent_organization FK
    root_id = "00000000-0000-0000-0000-000000000000"
    unless Workspace.exists?(id: root_id)
      sql = <<~SQL.squish
        INSERT INTO workspaces (id, name, domain, parent_organization, created_at, updated_at)
        VALUES ('#{root_id}', 'Root', 'root.local', '#{root_id}', NOW(), NOW())
      SQL
      Workspace.connection.execute(sql)
    end
  end

  test "valid workspace creation" do
    workspace = Workspace.new(
      name: "Acme Corp",
      domain: "acme-#{SecureRandom.hex(4)}.example.com",
    )
    assert_predicate workspace, :valid?
    assert workspace.save
  end

  test "requires name" do
    workspace = Workspace.new(domain: "noname-#{SecureRandom.hex(4)}.com")
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:name]
  end

  test "enforces unique domain" do
    domain = "unique-#{SecureRandom.hex(4)}.com"
    Workspace.create!(name: "First", domain: domain)
    duplicate = Workspace.new(name: "Second", domain: domain)

    assert_not duplicate.valid?
    assert_not_empty duplicate.errors[:domain]
  end

  test "boundary values: name cannot be empty" do
    workspace = Workspace.new(name: "", domain: "valid.com")
    assert_not workspace.valid?
    assert_not_empty workspace.errors[:name]
  end

  test "association deletion: destroys dependent roles" do
    workspace = Workspace.create!(
      name: "Role Test", domain: "role-#{SecureRandom.hex(4)}.com",
      parent_organization: "00000000-0000-0000-0000-000000000000",
    )
    role = Role.create!(name: "Custom Role", organization: workspace)

    assert_difference("Role.count", -1) do
      workspace.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { role.reload }
  end

  test "association deletion: destroys dependent user_memberships" do
    workspace = Workspace.create!(
      name: "Membership Test", domain: "mem-#{SecureRandom.hex(4)}.com",
      parent_organization: "00000000-0000-0000-0000-000000000000",
    )
    user = users(:one)
    membership = UserMembership.create!(user: user, workspace: workspace)

    assert_difference("UserMembership.count", -1) do
      workspace.destroy
    end
    assert_raise(ActiveRecord::RecordNotFound) { membership.reload }
  end
end
