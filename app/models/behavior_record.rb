# typed: false
# frozen_string_literal: true

class BehaviorRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :behavior, reading: :behavior_replica }
end
