# frozen_string_literal: true

module Help
  module Org
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
