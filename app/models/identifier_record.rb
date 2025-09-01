class IdentifierRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :identifier }
end
