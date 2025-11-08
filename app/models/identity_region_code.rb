# == Schema Information
#
# Table name: identifier_region_codes
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class IdentityRegionCode < UniversalRecord
  self.table_name = "identifier_region_codes"
end
