# typed: false
# frozen_string_literal: true

# Base exception class for application-wide custom errors
class ApplicationError < StandardError
  def initialize(i18n_key = nil, status_code = :internal_server_error, **context)
    @i18n_key = i18n_key
    @status_code = status_code
    @context = context

    if i18n_key
      message =
        if i18n_key.is_a?(String) && i18n_key.match?(/[^\x00-\x7F]/)
          i18n_key
        else
          I18n.t(i18n_key, **context)
        end
      super(message)
    else
      super(self.class.name)
    end
  end

  attr_reader :i18n_key, :status_code, :context
end
