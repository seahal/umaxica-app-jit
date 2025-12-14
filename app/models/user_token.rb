# frozen_string_literal: true

class UserToken < TokensRecord
  belongs_to :user
end
