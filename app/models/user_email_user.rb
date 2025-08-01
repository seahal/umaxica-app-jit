# frozen_string_literal: true

class UserEmailUser < IdentifiersRecord
  belongs_to :email, foreign_key: true, inverse_of: :user_email_users
  belongs_to :user, foreign_key: true, inverse_of: :user_email_users
end
