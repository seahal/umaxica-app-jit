# frozen_string_literal: true

class PreferenceRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :preference }
end
