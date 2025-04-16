# frozen_string_literal: true

class UserSession < SessionsRecord
  belongs_to :user
end
