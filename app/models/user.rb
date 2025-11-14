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
  has_many :user_emails, dependent: :destroy
  has_many :user_telephones, dependent: :destroy
  has_one :user_apple_auth, dependent: :destroy
  has_one :user_google_auth, dependent: :destroy
  has_many :user_sessions, dependent: :destroy
  has_many :user_time_based_one_time_password, dependent: :destroy
  has_many :user_webauthn_credentials, dependent: :destroy
  has_many :emails, class_name: "UserEmail", dependent: :destroy
  has_many :phones, class_name: "UserTelephone", dependent: :destroy
end
