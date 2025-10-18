module Api
  module App
    class HealthzController < ApplicationController
      include ::Healthz
    end
  end
end
