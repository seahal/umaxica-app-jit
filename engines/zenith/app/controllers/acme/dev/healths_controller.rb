# typed: strict
# frozen_string_literal: true

module Jit::Zenith::Acme::Dev
  class HealthsController < ActionController::API
    def show
      render json: { status: "pass" }
    end
  end
end
