# frozen_string_literal: true

class StoragesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :storage, reading: :storage_replica }
end
