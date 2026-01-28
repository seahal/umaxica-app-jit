# frozen_string_literal: true

class MessageRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :message, reading: :message_replica }
end
