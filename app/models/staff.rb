# frozen_string_literal: true

class Staff < AccountsRecord
  has_many :emails, foreign_key: "address"
end
