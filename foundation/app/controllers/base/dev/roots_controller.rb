# typed: strict
# frozen_string_literal: true

module Base::Dev
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "foundation", tier: "dev" }
    end
  end
end
