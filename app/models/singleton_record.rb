# frozen_string_literal: true

# SingletonRecord is a base class for models that should only have a single record.
# It ensures that only one instance of the model exists and provides convenient access to it.
class SingletonRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :singleton, reading: :singleton_replica }
end
