# typed: false
# frozen_string_literal: true

class PrincipalRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :principal, reading: :principal_replica }
end
