# frozen_string_literal: true

class TokensRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :token, reading: :token_replica }
end
