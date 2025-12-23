class TokensRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :token, reading: :token_replica }
end
