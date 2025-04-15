# frozen_string_literal: true

class MessageRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :message, reading: :message }
end
