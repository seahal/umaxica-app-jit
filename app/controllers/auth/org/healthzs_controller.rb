# frozen_string_literal: true

module Auth
  module Org
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
