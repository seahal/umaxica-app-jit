# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::Dev
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "distributor", tier: "dev" }
    end
  end
end
