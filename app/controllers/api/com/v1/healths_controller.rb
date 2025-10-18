# frozen_string_literal: true

module Apex
  module Com
    module V1
      class HealthsController < ApplicationController
        include ::Health
      end
    end
  end
end
