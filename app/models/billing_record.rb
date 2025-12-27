# frozen_string_literal: true

class BillingRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :billing }
end
