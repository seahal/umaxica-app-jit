# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::Net
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "distributor", tier: "net" }
    end
  end
end
