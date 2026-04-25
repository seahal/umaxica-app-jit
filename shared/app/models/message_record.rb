# typed: false
# frozen_string_literal: true

# Deployment scope: Local
# Region-specific. Each region (jp, us, etc.) has its own isolated database instance.
class MessageRecord < ApplicationRecord
  self.abstract_class = true
  unless Rails.env.test?

  connects_to database: { writing: :message, reading: :message_replica }
  end
end
