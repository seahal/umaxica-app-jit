# frozen_string_literal: true

module Api
  module App
    module V0
      class StagingsController < ApplicationController
        include ::Staging
      end
    end
  end
end
