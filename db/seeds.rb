# frozen_string_literal: true

raise '[SAFEGUARD] db:seed only use for dev env.' unless Rails.env.development?

#
# StaffEmailStaff.find_or_create_by(
#   staff: Staff.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c47'),
#   email: StaffEmail.find_or_create_by(address: 'first.staff@example.com'))

# UserEmailUser.find_or_create_by(
#   user: User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38'),
#   email: UserEmail.find_or_create_by(address: 'first.user@example.com')
# )

# CREATE IDENTIFIER REGION CODES
# RegionCode.create_or_find_by(id: 392)

# CREATE TERM
Document.find_or_create_by(id: '01000', parent_id: nil, prev_id: nil, succ_id: nil, title: 'TERM', description: '')
Document.find_or_create_by(id: '01001', parent_id: nil, prev_id: nil, succ_id: nil, title: 'PRIVACY', description: '')

# USER
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38')
User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c40')

#
ComContactCategory.create_or_find_by!(title: 'NULL_COM_CATEGORY', description: 'NULL')
ComContactCategory.create_or_find_by!(title: 'NULL', description: 'NULL')
ComContactCategory.create_or_find_by!(title: 'SECIRITY_ISSUE', description: 'root of corporate site status inquiries', parent_title: 'NULL')
ComContactCategory.create_or_find_by!(title: 'OTHERS', description: 'root of corporate site status inquiries', parent_title: 'NULL')
AppContactCategory.create_or_find_by!(title: 'NULL_APP_CATEGORY', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
OrgContactCategory.create_or_find_by!(title: 'NULL_ORG_CATEGORY', description: 'NULL')
OrgContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'APEX_OF_ORG', description: 'root of org site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries')
# #
# [ AppContactStatus, ComContactStatus, OrgContactStatus ].each do |status_class|
#   status_class.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
# end

AppContactStatus.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'null status')
AppContactStatus.create_or_find_by!(title: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries')
OrgContactStatus.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'null status')
OrgContactStatus.create_or_find_by!(title: 'ORG_SITE_STATUS', description: 'root of org site status inquiries')
OrgContactStatus.create_or_find_by!(title: 'ORG_SITE_STATUS', description: 'root of org site status inquiries')
ComContactStatus.create_or_find_by!(title: 'NULL_COM_STATUS', description: 'root of service site status inquiries')
ComContactStatus.create_or_find_by!(title: 'NULL', description: 'root of service site status inquiries')
ComContactStatus.create_or_find_by!(title: 'SET_UP', description: 'first step completed')
ComContactStatus.create_or_find_by!(title: 'CHECKED_EMAIL_ADDRESS', description: 'second step completed', parent_title: 'SET_UP')
ComContactStatus.create_or_find_by!(title: 'CHECKED_TELEPHONE_NUMBER', description: 'second step completed', parent_title: 'CHECKED_EMAIL_ADDRESS')
ComContactStatus.create_or_find_by!(title: 'COMPLETED_CONTACT_ACTION', description: 'second step completed', parent_title: 'CHECKED_TELEPHONE_NUMBER')
