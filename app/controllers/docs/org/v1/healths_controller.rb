# frozen_string_literal: true

module Docs
  module Org
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
