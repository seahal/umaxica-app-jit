# frozen_string_literal: true

module Api
  module Org
    module V1
      class StagingsController < ApplicationController
        include ::V1::Staging
      end
    end
  end
end
