# frozen_string_literal: true

class ProfilesRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :profile, reading: :profile_replica }
end
