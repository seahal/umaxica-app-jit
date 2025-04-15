# frozen_string_literal: true

class Staff < AccountRecord
  has_many :emails, foreign_key: "address"
end
