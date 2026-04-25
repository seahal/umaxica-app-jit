# typed: strict
# frozen_string_literal: true

module Post::Net
  class HealthsController < ActionController::API
    def show
      render json: { status: "pass" }
    end
  end
end
