# == Schema Information
#
# Table name: universal_user_identifiers
#
#  id              :uuid             not null, primary key
#  last_otp_at     :datetime         not null
#  otp_private_key :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
class UniversalUserIdentity < UniversalRecord
  self.table_name = "universal_user_identifiers"
end
