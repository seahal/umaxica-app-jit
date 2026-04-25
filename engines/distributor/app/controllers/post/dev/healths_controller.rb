# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::Dev
  class HealthsController < ActionController::API
    def show
      render json: { status: "pass" }
    end
  end
end
