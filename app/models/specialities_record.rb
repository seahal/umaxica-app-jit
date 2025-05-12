# frozen_string_literal: true

class SpecialitiesRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :speciality, reading: :speciality_replica }
end
