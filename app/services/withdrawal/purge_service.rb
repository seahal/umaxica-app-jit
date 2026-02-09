# frozen_string_literal: true

module Withdrawal
  class PurgeService
    def initialize(user)
      @user = user
    end

    def call
      # TODO: Implement PII cleanup and credential revocation in a future change.
      raise NotImplementedError, "PurgeService is not implemented yet"
    end
  end
end
