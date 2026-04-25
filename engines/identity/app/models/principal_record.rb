# typed: false
# frozen_string_literal: true

# Deployment scope: Global
# Shared worldwide. A single database instance serves all regions (jp, us, etc.).
class PrincipalRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :principal, reading: :principal_replica }

  private
end
