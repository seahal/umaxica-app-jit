# == Schema Information
#
# Table name: staff_recovery_codes
#
#  id              :uuid             not null, primary key
#  expires_in      :date
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class StaffRecoveryCode < IdentifiersRecord
end
