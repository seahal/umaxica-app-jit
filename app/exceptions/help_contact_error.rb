# frozen_string_literal: true

module Help
  # Base exception for help contact-related errors
  class ContactError < StandardError
    def initialize(i18n_key, status_code = :bad_request)
      @i18n_key = i18n_key
      @status_code = status_code
      super(I18n.t(i18n_key))
    end

    attr_reader :i18n_key, :status_code
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
      @current_status = current_status
      i18n_key = "help.contact.errors.invalid_status"
      message = I18n.t(i18n_key, current_status: current_status)
      @i18n_key = i18n_key
      @status_code = :unprocessable_entity
      StandardError.instance_method(:initialize).bind(self).call(message)
    end

    attr_reader :current_status
  end
end
