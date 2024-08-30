class User < ApplicationRecord
  has_many :emails, foreign_key: "id"
  has_many :phones, foreign_key: "id"
  has_one :user_apple_auth
  has_one :user_google_auth
  has_many :user_sessions
end
