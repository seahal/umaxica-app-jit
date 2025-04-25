3 # frozen_string_literal: true

class EntitiesRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :entity, reading: :entity_replica }
end
