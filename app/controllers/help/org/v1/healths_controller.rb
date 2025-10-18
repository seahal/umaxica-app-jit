# frozen_string_literal: true

module Help
  module Org
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
