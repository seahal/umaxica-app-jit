# frozen_string_literal: true

class MessagesRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :message, reading: :message_replica }
end
