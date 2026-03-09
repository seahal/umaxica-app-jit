# typed: false
# frozen_string_literal: true

class CspViolationsController < ApplicationController
  skip_forgery_protection

  def create
    if request.content_type&.include?("application/csp-report")
      report = request.body.read
      Rails.logger.warn("[CSP Violation] #{report}")
    end

    head :no_content
  end
end
