# typed: strict
# frozen_string_literal: true

module Jit::Identity::Sign::Dev
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "identity", tier: "dev" }
    end
  end
end
