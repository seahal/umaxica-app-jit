# typed: false
# frozen_string_literal: true

class CspViolationsController < ApplicationController
  protect_from_forgery with: :null_session

  def create
    if request.content_type&.include?("application/csp-report")
      report = request.body.read
      Rails.logger.warn("[CSP Violation] #{report}")
    end

    head :no_content
  end
end
