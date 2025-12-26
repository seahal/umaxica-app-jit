# frozen_string_literal: true

raise '[SAFEGUARD] db:seed only use for dev env.' unless Rails.env.development?

# ========================================
# DEVELOPMENT-ONLY DATA
# ========================================
#
# NOTE: Reference data (statuses, events, categories, etc.) has been moved to
# database-specific seed migrations and will be automatically seeded in all environments.
# This file contains ONLY development-specific sentinel records and test data.

# ========================================
# SENTINEL RECORDS (Development Only)
# ========================================

# USER
NIL_ACCOUNT_ID = "00000000-0000-0000-0000-000000000000"
User.find_or_create_by(id: NIL_ACCOUNT_ID) do |user|
  user.user_identity_status_id = "NONE"
  user.public_id = "nil_user"
  user.withdrawn_at = Time.zone.at(0)
end
Staff.find_or_create_by(id: NIL_ACCOUNT_ID) do |staff|
  staff.staff_identity_status_id = "NONE"
  staff.public_id = "nil_staff"
  staff.withdrawn_at = Time.zone.at(0)
end
# Test Users for development
User.find_or_create_by(id: "0191a0b6-1304-7c43-8248-0f13b4d29c38")
User.find_or_create_by(id: "0191a0b6-1304-7c43-8248-0f13b4d29c40")

# ========================================
# DEVELOPMENT WORKSPACE & RBAC
# ========================================

NIL_WORKSPACE_ID = "00000000-0000-0000-0000-000000000000"

# Sentinel workspace so parent_organization can default to a valid FK target
Workspace.find_or_create_by!(id: NIL_WORKSPACE_ID) do |workspace|
  workspace.name = "Nil Organization"
  workspace.domain = "nil.workspace"
  workspace.parent_organization = NIL_WORKSPACE_ID
end

# Create default organization
default_org = Workspace.find_or_create_by!(name: "Default Organization") do |org|
  org.domain = "localhost"
  org.parent_organization = NIL_WORKSPACE_ID
end

# Define roles with their keys, names, and descriptions
roles_data = [
  {
    key: "admin",
    name: "Administrator",
    description: I18n.t("seed.roles.admin.description"),
  },
  {
    key: "manager",
    name: "Manager",
    description: I18n.t("seed.roles.manager.description"),
  },
  {
    key: "editor",
    name: "Editor",
    description: I18n.t("seed.roles.editor.description"),
  },
  {
    key: "contributor",
    name: "Contributor",
    description: I18n.t("seed.roles.contributor.description"),
  },
  {
    key: "viewer",
    name: "Viewer",
    description: I18n.t("seed.roles.viewer.description"),
  },
]

# Create roles
roles_data.each do |role_data|
  role = Role.find_or_create_by!(
    key: role_data[:key],
    organization: default_org,
  ) do |r|
    r.name = role_data[:name]
    r.description = role_data[:description]
  end
  Rails.logger.debug { "  ✓ Role: #{role.name} (#{role.key})" }
end
