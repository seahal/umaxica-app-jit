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
# RegionCode.create_or_find_by(id: 392)

# CREATE TERM
# ComDocument.find_or_create_by(id: '01000', parent_id: nil, prev_id: nil, succ_id: nil, title: 'TERM', description: '')
# ComDocument.find_or_create_by(id: '01001', parent_id: nil, prev_id: nil, succ_id: nil, title: 'PRIVACY', description: '')

#
## UserIdentityStatus
UserIdentityStatus.create_or_find_by(id: "NONE")
UserIdentityStatus.create_or_find_by(id: "ALIVE")
UserIdentityStatus.create_or_find_by(id: "PRE_WITHDRAWAL_CONDITION")
UserIdentityStatus.create_or_find_by(id: "WITHDRAWAL_COMPLETED")
## StaffIdentityStatus
StaffIdentityStatus.create_or_find_by(id: "NONE")
StaffIdentityStatus.create_or_find_by(id: "ALIVE")
StaffIdentityStatus.create_or_find_by(id: "PRE_WITHDRAWAL_CONDITION")
StaffIdentityStatus.create_or_find_by(id: "WITHDRAWAL_COMPLETED")

# USER
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38')
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c40')

# CREATE CONTACT CATEGORY
ComContactCategory.create_or_find_by!(title: 'SECURITY_ISSUE', description: 'root of corporate site status inquiries', parent_title: 'NULL')
ComContactCategory.create_or_find_by!(title: 'OTHERS', description: 'root of corporate site status inquiries', parent_title: 'NULL')
AppContactCategory.create_or_find_by!(title: 'NULL', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.create_or_find_by!(title: 'COULD_NOT_SIGN_IN', description: 'user had a proble to sign/log in')
OrgContactCategory.create_or_find_by!(title: 'NULL_ORG_CATEGORY', description: 'NULL')
OrgContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'APEX_OF_ORG', description: 'root of org site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
OrgContactCategory.create_or_find_by!(title: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries')

# CREATE CONTACT STATUS
ComContactStatus.create_or_find_by!(title: 'NONE', description: 'root of service site status inquiries')
ComContactStatus.create_or_find_by!(title: 'SET_UP', description: 'first step completed')
ComContactStatus.create_or_find_by!(title: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: 'SET_UP')
ComContactStatus.create_or_find_by!(title: 'CHECKED_TELEPHONE_NUMBER', description: 'second step completed', parent_title: 'CHECKED_EMAIL_ADDRESS')
ComContactStatus.create_or_find_by!(title: 'COMPLETED_CONTACT_ACTION', description: 'second step completed', parent_title: 'CHECKED_TELEPHONE_NUMBER')
AppContactStatus.create_or_find_by!(title: 'NONE', description: 'null status')
AppContactStatus.create_or_find_by!(title: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries')
OrgContactStatus.create_or_find_by!(title: 'NONE', description: 'null status')
OrgContactStatus.create_or_find_by!(title: 'ORG_SITE_STATUS', description: 'root of org site status inquiries')
OrgContactStatus.create_or_find_by!(title: 'SET_UP', description: 'first step completed')
OrgContactStatus.create_or_find_by!(title: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: 'SET_UP')
OrgContactStatus.create_or_find_by!(title: 'CHECKED_TELEPHONE_NUMBER', description: 'third step completed', parent_title: 'CHECKED_EMAIL_ADDRESS')
OrgContactStatus.create_or_find_by!(title: 'COMPLETED_CONTACT_ACTION', description: 'contact action completed', parent_title: 'CHECKED_TELEPHONE_NUMBER')
