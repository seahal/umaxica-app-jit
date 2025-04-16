# frozen_string_literal: true

# MEMO: SHA3::Digest::SHA3_256.new(ENV['SINGLETON_DEFAULT_SALT'] + 'one@example.com').digest

class Email < AccountsRecord
  self.primary_key = :address

  has_one :user, foreign_key: "id"
  has_one :staff, foreign_key: "id"

  validates :address, length: 3..255,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
            uniqueness: { case_sensitive: false }
end
