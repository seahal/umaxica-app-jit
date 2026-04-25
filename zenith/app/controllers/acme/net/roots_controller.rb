# typed: strict
# frozen_string_literal: true

module Acme::Net
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "zenith", tier: "net" }
    end
  end
end
