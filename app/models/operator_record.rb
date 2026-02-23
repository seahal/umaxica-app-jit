# typed: false
# frozen_string_literal: true

class OperatorRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :operator, reading: :operator_replica }
end
