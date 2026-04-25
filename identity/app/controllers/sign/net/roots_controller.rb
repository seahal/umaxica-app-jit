# typed: strict
# frozen_string_literal: true

module Sign::Net
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "identity", tier: "net" }
    end
  end
end
