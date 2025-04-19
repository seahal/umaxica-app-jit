class AccountsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :account, reading: :account_replica }
end
