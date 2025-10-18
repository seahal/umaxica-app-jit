# frozen_string_literal: true

module Docs
  module Org
    class HealthsController < ApplicationController
      include ::Healthz
    end
  end
end
