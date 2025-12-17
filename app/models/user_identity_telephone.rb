# frozen_string_literal: true

# == Schema Information
#
# Table name: user_identity_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint
#  user_identity_telephone_status_id :string
#
# Indexes
#
#  index_user_identity_telephones_on_user_id  (user_id)
#  index_user_identity_telephones_on_user_identity_telephone_status_id  (user_identity_telephone_status_id)
#
class UserIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId
  include Turnstile

  belongs_to :user_identity_telephone_status, optional: true
  belongs_to :user, optional: true

  encrypts :number, deterministic: true
end
