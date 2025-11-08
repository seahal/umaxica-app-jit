# == Schema Information
#
# Table name: universal_telephone_identifiers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UniversalTelephoneIdentity < UniversalRecord
  self.table_name = "universal_telephone_identifiers"
end
