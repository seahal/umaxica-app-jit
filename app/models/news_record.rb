# typed: false
# frozen_string_literal: true

# Deployment scope: Local
# Region-specific. Each region (jp, us, etc.) has its own isolated database instance.
class NewsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :news, reading: :news_replica }
end
