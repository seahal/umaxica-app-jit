3 # frozen_string_literal: true

class StoragesRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :storage, reading: :storage_replica }
end
