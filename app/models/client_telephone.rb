# == Schema Information
#
# Table name: client_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class ClientTelephone < IdentifiersRecord
  include SetId
  include Telephone
end
