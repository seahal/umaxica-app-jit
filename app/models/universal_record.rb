# frozen_string_literal: true

# IdentifierRecord is a base class for models that should only have a single record.
# It ensures that only one instance of the model exists and provides convenient access to it.
class UniversalRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :universal, reading: :universal_replica }
end
