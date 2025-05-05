# frozen_string_literal: true

# == Schema Information
#
# Table name: users
#
#  id         :binary           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class User < IdentifiersRecord
  has_many :emails, foreign_key: "address"
  has_many :phones, foreign_key: "id"
  has_one :user_apple_auth
  has_one :user_google_auth
  has_many :user_sessions
  has_many :user_time_based_one_time_password
end
