# frozen_string_literal: true

module Test
  class SurfacesController < ApplicationController
    include ::RateLimit

    rate_limit_rule :test_surface_ip, scope: :ip, limit: 120, period: 1.minute

    def show
      render json: { surface: request.env[Core::Surface::ENV_KEY].to_s }
    end
  end
end
