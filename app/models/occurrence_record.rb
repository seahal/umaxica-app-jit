# frozen_string_literal: true

# NOTE: The occurrence database keeps globally unique identifiers.

# IdentityRecord is a base class for models that should only have a single record.
# It ensures that only one instance of the model exists and provides convenient access to it.

class OccurrenceRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :occurrence, reading: :occurrence_replica }
end
