# frozen_string_literal: true

module Api
  module Org
    module V0
      class StagingsController < ApplicationController
        include ::Staging
      end
    end
  end
end
