# frozen_string_literal: true

module Help
  # Base exception for help contact-related errors
  class ContactError < ApplicationError
    def initialize(i18n_key, status_code = :bad_request, **context)
      super(i18n_key, status_code, **context)
    end
  end

  # Raised when contact ID is missing or invalid
  class ContactNotFoundError < ContactError
    def initialize
      super("help.contact.errors.not_found", :not_found)
    end
  end

  # Raised when contact ID parameter is blank
  class ContactIdRequiredError < ContactError
    def initialize
      super("help.contact.errors.id_required", :bad_request)
    end
  end

  # Raised when contact has invalid status
  class InvalidContactStatusError < ContactError
    def initialize(current_status)
      super("help.contact.errors.invalid_status", :unprocessable_entity, current_status: current_status)
    end
  end
end
