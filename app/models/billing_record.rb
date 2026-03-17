# typed: false
# frozen_string_literal: true

# Deployment scope: Local
# Region-specific. Each region (jp, us, etc.) has its own isolated database instance.
class BillingRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :billing, reading: :billing_replica }
end
