# frozen_string_literal: true

class UserSession < TokensRecord
  belongs_to :user
end
