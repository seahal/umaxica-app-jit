# frozen_string_literal: true

module Help
  # Raised when contact ID is missing or invalid
  class ContactNotFoundError < ContactError
    def initialize
      super("help.contact.errors.not_found", :not_found)
    end
  end
end
