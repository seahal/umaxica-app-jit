# frozen_string_literal: true

module V1
  module Health
    extend ActiveSupport::Concern

    def show
      expires_in 1.second, public: true # this page wouldn't include private data

      if !!User.connection.execute("SELECT 1 FROM users LIMIT 1")
        render status: 200, json: { active: true }
      else
        render status: 500, json: { active: false }
      end
    end
  end
end
