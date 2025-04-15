# frozen_string_literal: true

class UserSession < AccountRecord
  belongs_to :user
end
