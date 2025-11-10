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
ComContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
AppContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
OrgContactCategory.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
ComContactCategory.create_or_find_by!(title: 'CORPORATE_SITE_CONTACT', description: 'root of corporate site status inquiries')
AppContactCategory.create_or_find_by!(title: 'SERVICE_SITE_CONTACT', description: 'root of service site status inquiries')
OrgContactCategory.create_or_find_by!(title: 'ORGANIZATION_SITE_CONTACT', description: 'root of org site status inquiries')

# #
# [ AppContactStatus, ComContactStatus, OrgContactStatus ].each do |status_class|
#   status_class.create_or_find_by!(title: 'NULL_CONTACT_STATUS', description: 'NULL')
# end

AppContactStatus.create_or_find_by!(title: 'STAFF_SITE_STATUS', description: 'root of staff site status inquiries')
ComContactStatus.create_or_find_by!(title: 'SERVICE_SITE_STATUS', description: 'root of service site status inquiries')
ComContactStatus.create_or_find_by!(title: 'CORPORATE_SITE_STATUS', description: 'root of corporate site status inquiries')
OrgContactStatus.create_or_find_by!(title: 'ORGANIZATION_SITE_STATUS', description: 'root of org site status inquiries')
ComContactStatus.create_or_find_by!(title: 'CORPORATE_SITE_SECURITY_ISSUE', description: 'security issue', parent_title: 'CORPORATE_SITE_STATUS')
ComContactStatus.create_or_find_by!(title: 'CORPORATE_SITE_OTHERS', description: 'others',  parent_title: 'CORPORATE_SITE_STATUS')
