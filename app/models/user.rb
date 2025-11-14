# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :uuid             not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
class User < IdentitiesRecord
  has_many :user_identity_emails, dependent: :destroy
  has_many :user_identity_telephones, dependent: :destroy
  has_one :user_identity_apple_auth, dependent: :destroy
  has_one :user_identity_google_auth, dependent: :destroy
  has_many :user_sessions, dependent: :destroy
  has_many :user_time_based_one_time_password, dependent: :destroy
  has_many :user_webauthn_credentials, dependent: :destroy
  has_many :emails, class_name: "UserIdentityEmail", dependent: :destroy
  has_many :phones, class_name: "UserIdentityTelephone", dependent: :destroy
end
