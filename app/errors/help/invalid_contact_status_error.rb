# frozen_string_literal: true

module Help
  # Raised when contact has invalid status
  class InvalidContactStatusError < ContactError
    def initialize(current_status)
      super("help.contact.errors.invalid_status", :unprocessable_entity, current_status: current_status)
    end
  end
end
