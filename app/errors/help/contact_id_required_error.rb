# frozen_string_literal: true

module Help
  # Raised when contact ID parameter is blank
  class ContactIdRequiredError < ContactError
    def initialize
      super("help.contact.errors.id_required", :bad_request)
    end
  end
end
