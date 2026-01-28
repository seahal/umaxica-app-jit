# frozen_string_literal: true

class TokenRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :token, reading: :token_replica }

  def as_json(options = {})
    # Exclude internal/sensitive/binary fields by default
    options[:except] =
      Array(options[:except]) | %i[id refresh_token_digest refresh_token_family_id refresh_token_generation]
    super(options)
  end
end
