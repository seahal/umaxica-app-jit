# typed: strict
# frozen_string_literal: true

module Jit::Zenith::Acme::Dev
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "zenith", tier: "dev" }
    end
  end
end
