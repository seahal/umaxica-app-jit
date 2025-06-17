# frozen_string_literal: true

module Api
  module App
    module V1
      class StagingsController < ApplicationController
        include ::Staging
      end
    end
  end
end
