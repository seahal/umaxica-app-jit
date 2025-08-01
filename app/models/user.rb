# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id          :binary           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  webauthn_id :string
#
class User < IdentifiersRecord
  has_many :emails, foreign_key: "address", dependent: :destroy, inverse_of: :user
  has_many :phones, foreign_key: "id", dependent: :destroy, inverse_of: :user
  has_one :user_apple_auth, dependent: :destroy
  has_one :user_google_auth, dependent: :destroy
  has_many :user_sessions, dependent: :destroy
  has_many :user_time_based_one_time_password, dependent: :destroy
  has_many :webauthns, dependent: :destroy
end
