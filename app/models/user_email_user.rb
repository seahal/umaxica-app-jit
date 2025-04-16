# frozen_string_literal: true

class UserEmailUser < AccountsRecord
  belongs_to :email, foreign_key: true
  belongs_to :user, foreign_key: true
end
