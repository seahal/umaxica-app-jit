# frozen_string_literal: true

class User < AccountsRecord
  has_many :emails, foreign_key: "address"
  has_many :phones, foreign_key: "id"
  has_one :user_apple_auth
  has_one :user_google_auth
  has_many :user_sessions
end
