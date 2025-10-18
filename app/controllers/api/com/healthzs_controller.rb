module Api
  module Com
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
