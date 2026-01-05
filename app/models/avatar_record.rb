# frozen_string_literal: true

class AvatarRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :avatar, reading: :avatar_replica }
end
