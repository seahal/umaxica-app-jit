class IdentifiersRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :identifier, reading: :identifier_replica }
end
