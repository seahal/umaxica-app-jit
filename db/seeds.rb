# frozen_string_literal: true

return if Rails.env.production?

sample_user_secret = "00000000000000000000000000000000"
sample_staff_secret = "11111111111111111111111111111111"

UserVisibility.find_or_create_by!(id: UserVisibility::STAFF)
UserStatus.find_or_create_by!(id: UserStatus::ACTIVE)
UserEmailStatus.find_or_create_by!(id: UserEmailStatus::VERIFIED)
UserSecretStatus.find_or_create_by!(id: UserSecretStatus::ACTIVE)
UserSecretKind.find_or_create_by!(id: UserSecretKind::PERMANENT)

StaffVisibility.find_or_create_by!(id: StaffVisibility::STAFF)
StaffStatus.find_or_create_by!(id: StaffStatus::ACTIVE)
StaffEmailStatus.find_or_create_by!(id: StaffEmailStatus::VERIFIED)
StaffSecretStatus.find_or_create_by!(id: StaffSecretStatus::ACTIVE)
StaffSecretKind.find_or_create_by!(id: StaffSecretKind::LOGIN)

user = User.find_or_initialize_by(public_id: "sample_user")
user.status_id = UserStatus::ACTIVE
user.save!

user_email = user.user_emails.find_or_initialize_by(address: "sample-user@example.test")
user_email.user_email_status_id = UserEmailStatus::VERIFIED
user_email.confirm_policy = true
user_email.save!

user_secret = user.user_secrets.find_or_initialize_by(name: "sample-user-secret")
user_secret.user_secret_kind_id = UserSecretKind::PERMANENT
user_secret.user_identity_secret_status_id = UserSecretStatus::ACTIVE
user_secret.uses_remaining = 10
user_secret.password = sample_user_secret
user_secret.save!

staff = Staff.find_or_initialize_by(public_id: "tmpl2345")
staff.status_id = StaffStatus::ACTIVE
staff.save!

staff_email = staff.staff_emails.find_or_initialize_by(address: "sample-staff@example.test")
staff_email.staff_email_status_id = StaffEmailStatus::VERIFIED
staff_email.save!

staff_secret = staff.staff_secrets.find_or_initialize_by(name: "sample-staff-secret")
staff_secret.staff_secret_kind_id = StaffSecretKind::LOGIN
staff_secret.staff_identity_secret_status_id = StaffSecretStatus::ACTIVE
staff_secret.password = sample_staff_secret
staff_secret.save!
