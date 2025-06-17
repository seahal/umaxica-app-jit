# frozen_string_literal: true

module Api
  module Com
    module V1
      class StagingsController < ApplicationController
        include ::Staging
      end
    end
  end
end
