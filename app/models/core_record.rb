# frozen_string_literal: true

class CoreRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :core, reading: :core_replica }
end
