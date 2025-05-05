# == Schema Information
#
# Table name: staff_recovery_codes
#
#  id              :bigint           not null, primary key
#  expire_in       :date
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class StaffRecoveryCode < IdentifiersRecord
end
