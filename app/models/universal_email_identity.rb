# == Schema Information
#
# Table name: universal_email_identifiers
#
#  id         :uuid             not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UniversalEmailIdentity < UniversalRecord
  self.table_name = "universal_email_identifiers"
end
