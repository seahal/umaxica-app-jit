# typed: strict
# frozen_string_literal: true

module Sign::Net
  class HealthsController < ActionController::API
    def show
      render json: { status: "pass" }
    end
  end
end
