# frozen_string_literal: true

class NotAuthenticatedError < ApplicationError
  def initialize(i18n_key = "errors.messages.login_required", status_code = :unauthorized, **context)
    super
  end
end
