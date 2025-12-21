# frozen_string_literal: true

module Help
  # Base exception for help contact-related errors
  class ContactError < ApplicationError
    def initialize(i18n_key, status_code = :bad_request, **context)
      super(i18n_key, status_code, **context)
    end
  end
end
