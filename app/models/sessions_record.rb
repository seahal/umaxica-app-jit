# frozen_string_literal: true

class SessionsRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :session, reading: :session_replica }
end
