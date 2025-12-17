# frozen_string_literal: true

# == Schema Information
#
# Table name: user_apple_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
class UserIdentityAppleAuth < IdentitiesRecord
  self.table_name = "user_apple_auths"

  belongs_to :user
  belongs_to :user_identity_apple_auth_status, optional: true

  validates :token, presence: true
  validates :user_id, uniqueness: true, allow_nil: true
end
