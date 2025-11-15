# == Schema Information
#
# Table name: user_identity_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#
# Indexes
#
#  index_user_identity_telephones_on_user_id  (user_id)
#
class UserIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId
end
