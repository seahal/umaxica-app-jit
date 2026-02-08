# frozen_string_literal: true

class ActivityRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :activity, reading: :activity }
end
