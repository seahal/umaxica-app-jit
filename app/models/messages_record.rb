# frozen_string_literal: true

class MessagesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :message, reading: :message_replica }
end
