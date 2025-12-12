# frozen_string_literal: true

# == Schema Information
#
# Table name: user_google_auths
#
#  id         :uuid             not null, primary key
#  token      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :uuid
#
class UserIdentityGoogleAuth < IdentitiesRecord
  self.table_name = "user_google_auths"

  belongs_to :user
  belongs_to :user_identity_google_auth_status, optional: true

  validates :token, presence: true
end
