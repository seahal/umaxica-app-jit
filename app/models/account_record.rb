# frozen_string_literal: true

class AccountRecord < ActiveRecord::Base
  self.abstract_class = true

  connects_to database: { writing: :account, reading: :account }
end
