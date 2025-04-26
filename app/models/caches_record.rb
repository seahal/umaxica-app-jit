class CachesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :cache, reading: :cache_replica }
end
