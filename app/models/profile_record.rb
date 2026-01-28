# frozen_string_literal: true

class ProfileRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :profile, reading: :profile_replica }
end
