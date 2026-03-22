# typed: false
# frozen_string_literal: true

class CspViolationsController < ApplicationController
  # FIXME: This configuration disables CSRF protection by nullifying the session
  # instead of raising an exception on invalid/missing tokens. This is a potential
  # security vulnerability, but is kept because this endpoint receives CSP
  # violation reports automatically sent by browsers via the Reporting API,
  # which cannot include CSRF tokens.
  # Consider implementing alternative security measures (e.g., origin validation,
  # rate limiting) to mitigate the risk.
  protect_from_forgery with: :null_session

  def create
    if request.content_type&.include?("application/csp-report")
      report = request.body.read
      Rails.logger.warn("[CSP Violation] #{report}")
    end

    head :no_content
  end
end
