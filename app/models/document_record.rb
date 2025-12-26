class DocumentRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :document, reading: :document }
end
