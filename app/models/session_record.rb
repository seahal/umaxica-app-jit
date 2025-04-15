# frozen_string_literal: true

class SessionRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :session, reading: :session_replica }
end
