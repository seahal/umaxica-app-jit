# frozen_string_literal: true

class IdentityRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :identity, reading: :identity_replica }
end
