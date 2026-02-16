# frozen_string_literal: true

module Test
  class SurfacesController < ApplicationController
    def show
      render json: { surface: request.env[Core::Surface::ENV_KEY].to_s }
    end
  end
end
