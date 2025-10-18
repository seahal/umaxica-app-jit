# frozen_string_literal: true

module News
  module Org
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
