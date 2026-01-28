# frozen_string_literal: true

class AlreadyAuthenticatedError < ApplicationError
  def initialize(i18n_key = "errors.messages.already_authenticated", status_code = :forbidden, **context)
    super
  end
end
