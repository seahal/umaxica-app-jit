# frozen_string_literal: true

class GuestsRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :guest, reading: :guest_replica }
end
