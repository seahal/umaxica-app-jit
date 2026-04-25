# typed: strict
# frozen_string_literal: true

module Jit::Foundation::Base::Net
  class RootsController < ActionController::API
    def index
      render json: { status: "ok", service: "foundation", tier: "net" }
    end
  end
end
