# frozen_string_literal: true

class GuestRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :guest, reading: :guest_replica }
end
