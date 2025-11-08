# == Schema Information
#
# Table name: universal_staff_identifiers
#
#  id              :uuid             not null, primary key
#  last_otp_at     :datetime         not null
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UniversalStaffIdentity < UniversalRecord
  self.table_name = "universal_staff_identifiers"
end
