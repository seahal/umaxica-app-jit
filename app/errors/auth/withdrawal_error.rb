# frozen_string_literal: true

module Auth
  # Base exception for withdrawal-related errors
  class WithdrawalError < ApplicationError
    def initialize(i18n_key, status_code = :bad_request, **context)
      super(i18n_key, status_code, **context)
    end
  end

  # Raised when withdrawal cannot be shown due to invalid user state
  class InvalidWithdrawalStateError < WithdrawalError
    def initialize(current_status)
      super("sign.withdrawal.errors.invalid_state", :unprocessable_entity, current_status: current_status)
    end
  end

  # Raised when attempting recovery outside the allowed window
  class WithdrawalRecoveryNotAvailableError < WithdrawalError
    def initialize
      super("sign.withdrawal.errors.recovery_not_available", :unprocessable_entity)
    end
  end

  # Raised when account deletion fails
  class WithdrawalDeletionError < WithdrawalError
    def initialize
      super("sign.withdrawal.errors.deletion_failed", :internal_server_error)
    end
  end
end
