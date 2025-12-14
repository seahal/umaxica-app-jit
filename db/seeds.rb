# frozen_string_literal: true

raise '[SAFEGUARD] db:seed only use for dev env.' unless Rails.env.development?

#
# StaffIdentityEmailStaff.find_or_create_by(
#   staff: Staff.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c47'),
#   email: StaffIdentityEmail.find_or_create_by(address: 'first.staff@example.com'))

# UserIdentityEmailUser.find_or_create_by(
#   user: User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38'),
#   email: UserIdentityEmail.find_or_create_by(address: 'first.user@example.com')
# )

# CREATE IDENTIFIER REGION CODES
# RegionCode.find_or_create_by(id: 392)

# CREATE TERM
# ComDocument.find_or_create_by(id: '01000', parent_id: nil, prev_id: nil, succ_id: nil, title: 'TERM', description: '')
# ComDocument.find_or_create_by(id: '01001', parent_id: nil, prev_id: nil, succ_id: nil, title: 'PRIVACY', description: '')

#
## UserIdentityStatus
UserIdentityStatus.find_or_create_by(id: "NONE")
UserIdentityStatus.find_or_create_by(id: "ALIVE")
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

# USER
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38')
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c40')
#
UserIdentitySecretStatus.find_or_create_by!(id: 'ACTIVE')
UserIdentitySecretStatus.find_or_create_by!(id: 'SUSPENDED')

# CREATE CONTACT CATEGORY
ComContactCategory.find_or_create_by!(title: 'SECURITY_ISSUE', description: 'root of corporate site status inquiries', parent_title: 'NULL')
ComContactCategory.find_or_create_by!(title: 'OTHERS', description: 'root of corporate site status inquiries', parent_title: 'NULL')
AppContactCategory.find_or_create_by!(title: 'NULL', description: 'NULL')
AppContactCategory.find_or_create_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.find_or_create_by!(title: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.find_or_create_by!(title: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.find_or_create_by!(title: 'NULL_ORG_CATEGORY', description: 'NULL')
OrgContactCategory.find_or_create_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.find_or_create_by!(title: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.find_or_create_by!(title: 'APEX_OF_ORG', description: 'root of org site status inquiries')
OrgContactCategory.find_or_create_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
OrgContactCategory.find_or_create_by!(title: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries')

# CREATE CONTACT STATUS
ComContactStatus.find_or_create_by!(id: 'NONE', description: 'root of service site status inquiries')
ComContactStatus.find_or_create_by!(id: 'SET_UP', description: 'first step completed')
ComContactStatus.find_or_create_by!(id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: 'SET_UP')
ComContactStatus.find_or_create_by!(id: 'CHECKED_TELEPHONE_NUMBER', description: 'second step completed', parent_title: 'CHECKED_EMAIL_ADDRESS')
ComContactStatus.find_or_create_by!(id: 'COMPLETED_CONTACT_ACTION', description: 'second step completed', parent_title: 'CHECKED_TELEPHONE_NUMBER')
AppContactStatus.find_or_create_by!(id: 'NONE', description: 'null status')
AppContactStatus.find_or_create_by!(id: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries')
OrgContactStatus.find_or_create_by!(id: 'NONE', description: 'null status')
OrgContactStatus.find_or_create_by!(id: 'ORG_SITE_STATUS', description: 'root of org site status inquiries')
OrgContactStatus.find_or_create_by!(id: 'SET_UP', description: 'first step completed')
OrgContactStatus.find_or_create_by!(id: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: 'SET_UP')
OrgContactStatus.find_or_create_by!(id: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_title: 'CHECKED_EMAIL_ADDRESS')
OrgContactStatus.find_or_create_by!(id: 'COMPLETED_CONTACT_ACTION', description: 'contact action completed', parent_title: 'CHECKED_TELEPHONE_NUMBER')
