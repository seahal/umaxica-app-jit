# typed: false
# frozen_string_literal: true

# Deployment scope: Global
# Shared worldwide. A single database instance serves all regions (jp, us, etc.).
class TokenRecord < ApplicationRecord
  self.abstract_class = true
  unless Rails.env.test?

  connects_to database: { writing: :token, reading: :token_replica }
  end

  private

  def as_json(options = {})
    # Exclude internal/sensitive/binary fields by default
    options[:except] =
      Array(options[:except]) | %i(id refresh_token_digest refresh_token_family_id refresh_token_generation)
    super(options)
  end
end
