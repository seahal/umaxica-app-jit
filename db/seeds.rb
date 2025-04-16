# frozen_string_literal: true

raise '[SAFEGUARD] db:seed only use for dev env.' unless Rails.env.development?

#
# StaffEmailStaff.find_or_create_by(
#   staff: Staff.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c47'),
#   email: StaffEmail.find_or_create_by(address: 'first.staff@example.com'))

UserEmailUser.find_or_create_by(
  user: User.find_or_create_by(id: '0191a0b6-1304-7c43-8248-0f13b4d29c38'),
  email: UserEmail.find_or_create_by(address: 'first.user@example.com')
)
