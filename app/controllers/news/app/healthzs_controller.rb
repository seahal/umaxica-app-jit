# frozen_string_literal: true

module News
  module App
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
