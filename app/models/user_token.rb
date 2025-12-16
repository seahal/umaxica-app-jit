# frozen_string_literal: true

class UserToken < TokensRecord
  belongs_to :user
  belongs_to :user_token_status
end
