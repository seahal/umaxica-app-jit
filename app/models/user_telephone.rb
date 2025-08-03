# == Schema Information
#
# Table name: user_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class UserTelephone < IdentifiersRecord
  include Telephone
  include SetId
end
