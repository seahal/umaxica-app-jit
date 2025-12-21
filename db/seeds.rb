# frozen_string_literal: true

raise '[SAFEGUARD] db:seed only use for dev env.' unless Rails.env.development?

#
## UserIdentityStatus
UserIdentityStatus.find_or_create_by(id: "NONE")
UserIdentityStatus.find_or_create_by(id: "ALIVE")
UserIdentityStatus.find_or_create_by(id: "VERIFIED_WITH_SIGN_UP")
UserIdentityStatus.find_or_create_by(id: "PRE_WITHDRAWAL_CONDITION")
UserIdentityStatus.find_or_create_by(id: "WITHDRAWAL_COMPLETED")
## UserIdentityEmailStatus
#
UserIdentityEmailStatus.find_or_create_by(id: "NONE")
UserIdentityEmailStatus.find_or_create_by(id: "UNVERIFIED_WITH_SIGN_UP")
UserIdentityEmailStatus.find_or_create_by(id: "VERIFIED_WITH_SIGN_UP")
UserIdentityEmailStatus.find_or_create_by(id: "ALIVE")
UserIdentityEmailStatus.find_or_create_by(id: "SUSPENDED")
UserIdentityEmailStatus.find_or_create_by(id: "DELETED")
## UserIdentityTelephoneStatus
UserIdentityTelephoneStatus.find_or_create_by(id: "NONE")
UserIdentityTelephoneStatus.find_or_create_by(id: "UNVERIFIED_WITH_SIGN_UP")
UserIdentityTelephoneStatus.find_or_create_by(id: "VERIFIED_WITH_SIGN_UP")
UserIdentityTelephoneStatus.find_or_create_by(id: "ALIVE")
UserIdentityTelephoneStatus.find_or_create_by(id: "SUSPENDED")
UserIdentityTelephoneStatus.find_or_create_by(id: "DELETED")
## StaffIdentityStatus
StaffIdentityStatus.find_or_create_by(id: "NONE")
StaffIdentityStatus.find_or_create_by(id: "ALIVE")
StaffIdentityStatus.find_or_create_by(id: "PRE_WITHDRAWAL_CONDITION")
StaffIdentityStatus.find_or_create_by(id: "WITHDRAWAL_COMPLETED")
## StaffIdentityEmailStatus
StaffIdentityEmailStatus.find_or_create_by(id: "UNVERIFIED_WITH_SIGN_UP")
StaffIdentityEmailStatus.find_or_create_by(id: "VERIFIED_WITH_SIGN_UP")
StaffIdentityEmailStatus.find_or_create_by(id: "ALIVE")
StaffIdentityEmailStatus.find_or_create_by(id: "SUSPENDED")
StaffIdentityEmailStatus.find_or_create_by(id: "DELETED")
## StaffIdentityTelephoneStatus
StaffIdentityTelephoneStatus.find_or_create_by(id: "UNVERIFIED_WITH_SIGN_UP")
StaffIdentityTelephoneStatus.find_or_create_by(id: "VERIFIED_WITH_SIGN_UP")
StaffIdentityTelephoneStatus.find_or_create_by(id: "ALIVE")
StaffIdentityTelephoneStatus.find_or_create_by(id: "SUSPENDED")
StaffIdentityTelephoneStatus.find_or_create_by(id: "DELETED")
#
UserIdentityAuditEvent.find_or_create_by!(id: 'SIGNED_UP_WITH_EMAIL')
UserIdentityAuditEvent.find_or_create_by!(id: 'SIGNED_UP_WITH_TELEPHONE')
UserIdentityAuditEvent.find_or_create_by!(id: 'SIGNED_UP_WITH_APPLE')
UserIdentityAuditEvent.find_or_create_by!(id: 'SIGNED_UP_WITH_GOOGLE')
UserIdentityAuditEvent.find_or_create_by!(id: 'AUTHORIZATION_FAILED')

StaffIdentityAuditEvent.find_or_create_by!(id: 'AUTHORIZATION_FAILED')

# USER
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38')
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c40')
#
UserIdentitySecretStatus.find_or_create_by!(id: 'ACTIVE')
UserIdentitySecretStatus.find_or_create_by!(id: 'SUSPENDED')
StaffIdentitySecretStatus.find_or_create_by!(id: "ACTIVE")
StaffIdentitySecretStatus.find_or_create_by!(id: "USED")
StaffIdentitySecretStatus.find_or_create_by!(id: "REVOKED")
StaffIdentitySecretStatus.find_or_create_by!(id: "DELETED")

# CREATE CONTACT CATEGORY
ComContactCategory.find_or_create_by!(id: 'SECURITY_ISSUE', description: 'root of corporate site status inquiries', parent_id: 'NULL')
ComContactCategory.find_or_create_by!(id: 'OTHERS', description: 'root of corporate site status inquiries', parent_id: 'NULL')
AppContactCategory.find_or_create_by!(id: 'NULL', description: 'NULL')
AppContactCategory.find_or_create_by!(id: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.find_or_create_by!(id: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.find_or_create_by!(id: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.find_or_create_by!(id: 'NULL_ORG_CATEGORY', description: 'NULL')
OrgContactCategory.find_or_create_by!(id: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.find_or_create_by!(id: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.find_or_create_by!(id: 'APEX_OF_ORG', description: 'root of org site status inquiries')
OrgContactCategory.find_or_create_by!(id: 'NULL_CONTACT_STATUS', description: 'NULL')
OrgContactCategory.find_or_create_by!(id: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries')

# CREATE CONTACT STATUS
ComContactStatus.find_or_create_by!(id: 'NONE', description: 'root of service site status inquiries')
ComContactStatus.find_or_create_by!(id: 'SET_UP', description: 'first step completed')
ComContactStatus.find_or_create_by!(id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_id: 'SET_UP')
ComContactStatus.find_or_create_by!(id: 'CHECKED_TELEPHONE_NUMBER', description: 'second step completed', parent_id: 'CHECKED_EMAIL_ADDRESS')
ComContactStatus.find_or_create_by!(id: 'COMPLETED_CONTACT_ACTION', description: 'second step completed', parent_id: 'CHECKED_TELEPHONE_NUMBER')
AppContactStatus.find_or_create_by!(id: 'NONE', description: 'null status')
AppContactStatus.find_or_create_by!(id: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries')
OrgContactStatus.find_or_create_by!(id: 'NONE', description: 'null status')
OrgContactStatus.find_or_create_by!(id: 'ORG_SITE_STATUS', description: 'root of org site status inquiries')
OrgContactStatus.find_or_create_by!(id: 'SET_UP', description: 'first step completed')
OrgContactStatus.find_or_create_by!(id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_id: 'SET_UP')
OrgContactStatus.find_or_create_by!(id: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_id: 'CHECKED_EMAIL_ADDRESS')
OrgContactStatus.find_or_create_by!(id: 'COMPLETED_CONTACT_ACTION', description: 'contact action completed', parent_id: 'CHECKED_TELEPHONE_NUMBER')

# Timeline Audit Events
ComTimelineAuditEvent.find_or_create_by!(id: "NONE")
ComTimelineAuditEvent.find_or_create_by!(id: "CREATED")
ComTimelineAuditEvent.find_or_create_by!(id: "UPDATED")
ComTimelineAuditEvent.find_or_create_by!(id: "DESTROYED")

OrgTimelineAuditEvent.find_or_create_by!(id: "NONE")
OrgTimelineAuditEvent.find_or_create_by!(id: "CREATED")
OrgTimelineAuditEvent.find_or_create_by!(id: "UPDATED")
OrgTimelineAuditEvent.find_or_create_by!(id: "DESTROYED")

AppTimelineAuditEvent.find_or_create_by!(id: "NONE")
AppTimelineAuditEvent.find_or_create_by!(id: "CREATED")
AppTimelineAuditEvent.find_or_create_by!(id: "UPDATED")
AppTimelineAuditEvent.find_or_create_by!(id: "DESTROYED")

# Contact Audit Events
ComContactAuditEvent.find_or_create_by!(id: "NONE")
ComContactAuditEvent.find_or_create_by!(id: "CREATED")
ComContactAuditEvent.find_or_create_by!(id: "UPDATED")
ComContactAuditEvent.find_or_create_by!(id: "DESTROYED")

AppContactAuditEvent.find_or_create_by!(id: "NONE")
AppContactAuditEvent.find_or_create_by!(id: "CREATED")
AppContactAuditEvent.find_or_create_by!(id: "UPDATED")
AppContactAuditEvent.find_or_create_by!(id: "DESTROYED")

OrgContactAuditEvent.find_or_create_by!(id: "NONE")
OrgContactAuditEvent.find_or_create_by!(id: "CREATED")
OrgContactAuditEvent.find_or_create_by!(id: "UPDATED")
OrgContactAuditEvent.find_or_create_by!(id: "DESTROYED")

# ========================================
# ROLE-BASED ACCESS CONTROL (RBAC)
# ========================================

# Create default organization
default_org = Workspace.find_or_create_by!(name: "Default Organization") do |org|
  org.domain = "localhost"
end

# Define roles with their keys, names, and descriptions
roles_data = [
  {
    key: "admin",
    name: "Administrator",
    description: I18n.t("seed.roles.admin.description")
  },
  {
    key: "manager",
    name: "Manager",
    description: I18n.t("seed.roles.manager.description")
  },
  {
    key: "editor",
    name: "Editor",
    description: I18n.t("seed.roles.editor.description")
  },
  {
    key: "contributor",
    name: "Contributor",
    description: I18n.t("seed.roles.contributor.description")
  },
  {
    key: "viewer",
    name: "Viewer",
    description: I18n.t("seed.roles.viewer.description")
  }
]

# Create roles
roles_data.each do |role_data|
  role = Role.find_or_create_by!(
    key: role_data[:key],
    organization: default_org
  ) do |r|
    r.name = role_data[:name]
    r.description = role_data[:description]
  end
  Rails.logger.debug { "  ✓ Role: #{role.name} (#{role.key})" }
end
