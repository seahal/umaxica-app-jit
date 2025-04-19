# frozen_string_literal: true

module Api
  module Com
    module V0
      class StagingsController < ApplicationController
        include ::Staging
      end
    end
  end
end
