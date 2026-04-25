# typed: false
# frozen_string_literal: true

# Deployment scope: Global
# Shared worldwide. A single database instance serves all regions (jp, us, etc.).
class OperatorRecord < ApplicationRecord
  self.abstract_class = true
  unless Rails.env.test?

  connects_to database: { writing: :operator, reading: :operator_replica }
  end

  private
end
