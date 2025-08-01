# == Schema Information
#
# Table name: user_telephones
#
#  id         :binary           not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid_id    :uuid             not null
#
class UserTelephone < IdentifiersRecord
  include Telephone
  include SetId
end
