# frozen_string_literal: true

module News
  module Com
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
